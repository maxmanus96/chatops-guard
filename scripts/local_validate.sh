#!/usr/bin/env bash
set -euo pipefail

section() {
  printf '\n==> %s\n' "$1"
}

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 127
  fi
}

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

# Keep Azure CLI session writes out of sandboxed or read-only home directories.
export AZURE_CONFIG_DIR="${AZURE_CONFIG_DIR:-${TMPDIR:-/tmp}/chatops-guard-azure-cli}"
mkdir -p "$AZURE_CONFIG_DIR"
TF_DATA_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/chatops-guard-tfdata.XXXXXX")"

need actionlint
need checkov
need python3
need ruby
need terraform

terraform_dirs=(
  infra/envs/dev
  infra/envs/dev-platform
)

for module_dir in infra/modules/*; do
  if [ -d "$module_dir" ] && find "$module_dir" -maxdepth 1 -name '*.tf' -print -quit | grep -q .; then
    terraform_dirs+=("$module_dir")
  fi
done

section "Tool versions"
terraform version
printf 'checkov %s\n' "$(checkov --version)"
python3 -c 'import yaml; print(f"PyYAML {yaml.__version__}")'
ruby --version
actionlint -version

section "YAML parse with PyYAML"
python3 - <<'PY'
from pathlib import Path
import yaml

paths = sorted(Path(".github/workflows").glob("*.yaml"))
paths += sorted(Path(".github/workflows").glob("*.yml"))
dependabot = Path(".github/dependabot.yml")
if dependabot.exists():
    paths.append(dependabot)

for path in paths:
    yaml.safe_load(path.read_text())
    print(f"OK {path}")
PY

section "YAML parse with Ruby"
ruby -e 'require "yaml"; (Dir[".github/workflows/*.{yaml,yml}"] + [".github/dependabot.yml"]).select { |p| File.exist?(p) }.sort.each { |p| YAML.load_file(p); puts "OK #{p}" }'

section "GitHub Actions lint"
actionlint -shellcheck= -color

section "Terraform format"
terraform fmt -check -recursive infra

section "Terraform init and validate"
for dir in "${terraform_dirs[@]}"; do
  printf '\n-- %s\n' "$dir"
  tf_data_dir="${TF_DATA_ROOT}/${dir//\//_}"
  mkdir -p "$tf_data_dir"
  TF_DATA_DIR="$tf_data_dir" terraform -chdir="$dir" init -backend=false -input=false
  TF_DATA_DIR="$tf_data_dir" terraform -chdir="$dir" validate
done

section "Checkov active Terraform roots"
checkov -d infra/envs/dev --framework terraform --quiet
checkov -d infra/envs/dev-platform --framework terraform --quiet

section "Local validation complete"
