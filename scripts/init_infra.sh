#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# init_infra.sh — One-time bootstrap for Terraform remote state + Azure OIDC SP
# Requires: az CLI (logged in), jq, (optional) gh CLI for secrets
# Usage:
#   GH_REPO="maxmanus96/chatops-guard" ./scripts/init_infra.sh
# Optional env vars you can override:
#   LOCATION (westeurope), STATE_RG, SA_NAME, CONTAINER, APP_NAME, BRANCH

# -----------------------------------------------------------------------------
# and how to run? (see following lines as example)
#chmod +x scripts/init_infra.sh
#GH_REPO="maxmanus96/chatops-guard" ./scripts/init_infra.sh
# (optional) push secrets directly to GitHub if you have gh CLI:
#SET_GH_SECRETS=true GH_REPO="maxmanus96/chatops-guard" ./scripts/init_infra.sh
# -----------------------------------------------------------------------------
set -euo pipefail

# -------- config (override via env) ------------------------------------------
GH_REPO="${GH_REPO:-maxmanus96/chatops-guard}"   # owner/repo
LOCATION="${LOCATION:-westeurope}"
STATE_RG="${STATE_RG:-rg-chatops-guard-state}"
SA_NAME="${SA_NAME:-chatopsstateguard01}"        # 3–24 chars, lowercase, globally unique
CONTAINER="${CONTAINER:-tfstate}"
APP_NAME="${APP_NAME:-chatops-guard-gh}"         # Azure AD application (service principal)
BRANCH="${BRANCH:-main}"                         # branch for OIDC subject
SET_GH_SECRETS="${SET_GH_SECRETS:-false}"        # true to push secrets with gh CLI
# -----------------------------------------------------------------------------

need() { command -v "$1" >/dev/null || { echo "✖ Missing '$1'"; exit 1; }; }
need az
need jq

echo "▶ Checking Azure login / subscription…"
SUBSCRIPTION_ID="$(az account show --query id -o tsv 2>/dev/null || true)"
TENANT_ID="$(az account show --query tenantId -o tsv 2>/dev/null || true)"
if [[ -z "$SUBSCRIPTION_ID" || -z "$TENANT_ID" ]]; then
  echo "✖ Not logged in. Run: az login --use-device-code"; exit 1
fi
az account set --subscription "$SUBSCRIPTION_ID"
echo "   Subscription: $SUBSCRIPTION_ID"

echo "▶ Ensuring resource group '$STATE_RG' in '$LOCATION'…"
az group create -n "$STATE_RG" -l "$LOCATION" 1>/dev/null

# Storage account: plain StorageV2 (NO HNS) so blob versioning is supported
if ! az storage account show -n "$SA_NAME" -g "$STATE_RG" >/dev/null 2>&1; then
  echo "▶ Creating storage account '$SA_NAME'…"
  if [[ "$(az storage account check-name --name "$SA_NAME" --query nameAvailable -o tsv)" != "true" ]]; then
    echo "✖ SA name '$SA_NAME' unavailable. Set SA_NAME to another value and re-run."; exit 2
  fi
  az storage account create \
    --name "$SA_NAME" \
    --resource-group "$STATE_RG" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 1>/dev/null
else
  echo "✓ Storage account exists."
fi

echo "▶ Ensuring container '$CONTAINER' (AAD if possible)…"
if ! az storage container create --account-name "$SA_NAME" --name "$CONTAINER" --auth-mode login 1>/dev/null 2>&1; then
  echo "… AAD path failed; falling back to account key."
  SA_KEY="$(az storage account keys list -n "$SA_NAME" -g "$STATE_RG" --query '[0].value' -o tsv)"
  az storage container create --account-name "$SA_NAME" --name "$CONTAINER" --account-key "$SA_KEY" 1>/dev/null
fi

echo "▶ Enabling blob versioning…"
az storage account blob-service-properties update \
  --account-name "$SA_NAME" \
  --resource-group "$STATE_RG" \
  --enable-versioning true 1>/dev/null

SA_ID="$(az storage account show -n "$SA_NAME" -g "$STATE_RG" --query id -o tsv)"

echo "▶ Creating / locating Entra application '$APP_NAME'…"
APP_JSON="$(az ad app list --display-name "$APP_NAME" -o json)"
if [[ "$(echo "$APP_JSON" | jq 'length')" == "0" ]]; then
  APP_ID="$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)"
  az ad sp create --id "$APP_ID" 1>/dev/null
else
  APP_ID="$(echo "$APP_JSON" | jq -r '.[0].appId')"
  # ensure SP exists
  az ad sp show --id "$APP_ID" >/dev/null 2>&1 || az ad sp create --id "$APP_ID" 1>/dev/null
fi
SP_OBJ_ID="$(az ad sp show --id "$APP_ID" --query id -o tsv)"
echo "   AppId: $APP_ID  SP ObjectId: $SP_OBJ_ID"

echo "▶ Ensuring federated credential for repo:$GH_REPO branch:$BRANCH…"
SUBJECT="repo:$GH_REPO:ref:refs/heads/$BRANCH"
# Try to create blindly; ignore if exists
az ad app federated-credential create --id "$APP_ID" \
  --display-name "gha-$BRANCH" \
  --issuer "https://token.actions.githubusercontent.com" \
  --audience "api://AzureADTokenExchange" \
  --subject "$SUBJECT" >/dev/null 2>&1 || true
az ad app federated-credential create --id "$APP_ID" --parameters '{
  "name": "gha-pr",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:maxmanus96/chatops-guard:pull_request",
  "audiences": ["api://AzureADTokenExchange"]
}'

echo "▶ Assigning roles…"
SCOPE_SUB="/subscriptions/$SUBSCRIPTION_ID"
# Contributor at subscription (simple); you can later narrow to RG scopes
az role assignment create --assignee "$APP_ID" --role "Contributor" --scope "$SCOPE_SUB" >/dev/null 2>&1 || true
# Storage Blob Data Contributor on the state storage account
az role assignment create --assignee "$APP_ID" --role "Storage Blob Data Contributor" --scope "$SA_ID" >/dev/null 2>&1 || true
echo "✓ Role assignments ensured."

echo "▶ GitHub secrets payload:"
echo "   AZURE_CLIENT_ID=$APP_ID"
echo "   AZURE_TENANT_ID=$TENANT_ID"
echo "   AZURE_SUBSCRIPTION_ID=$SUBSCRIPTION_ID"

if [[ "$SET_GH_SECRETS" == "true" ]]; then
  need gh
  echo "▶ Writing GitHub repo secrets to $GH_REPO …"
  gh secret set AZURE_CLIENT_ID        -R "$GH_REPO" -b "$APP_ID"
  gh secret set AZURE_TENANT_ID        -R "$GH_REPO" -b "$TENANT_ID"
  gh secret set AZURE_SUBSCRIPTION_ID  -R "$GH_REPO" -b "$SUBSCRIPTION_ID"
  echo "✓ Secrets set."
fi

cat <<EOF

──────────────────────── Terraform backend snippet ────────────────────────
# infra/envs/dev/backend.tf
terraform {
  backend "azurerm" {
    resource_group_name   = "$STATE_RG"
    storage_account_name  = "$SA_NAME"
    container_name        = "$CONTAINER"
    key                   = "infra-dev.tfstate"
    # If your backend supports AAD explicitly:
    # use_azuread_auth = true
  }
}
───────────────────────────────────────────────────────────────────────────

Now run:
  cd infra/envs/dev
  terraform init -reconfigure
  terraform plan
EOF

# Optional: run init automatically if directory exists
if [[ -d "infra/envs/dev" ]]; then
  echo "▶ Running terraform init -reconfigure (infra/envs/dev)…"
  (cd infra/envs/dev && terraform init -reconfigure) || true
fi

echo "✅ init_infra completed."

# Prod Bootstrap Steps

# export prod-specific values and rerun the existing script:
# STATE_RG=rg-chatops-guard-prod-state SA_NAME=chatopsstateprod01 CONTAINER=tfstate-prod LOCATION=westeurope APP_NAME=chatops-guard-gh-prod BRANCH=main GH_REPO="maxmanus96/chatops-guard" ./scripts/init_infra.sh
# Let the script create/enforce the prod RG, storage account, container, blob versioning, Azure AD app/SP, federated credentials, and role assignments just like it does for dev.
# Copy the backend snippet it prints and update infra/envs/prod/backend.tf (use a prod-specific key, e.g. infra-prod.tfstate; set required_version/required_providers if not already there).
# Run terraform init -reconfigure inside infra/envs/prod so Terraform points at the new state backend.