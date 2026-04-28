resource "azurerm_container_registry" "this" {
  #checkov:skip=CKV_AZURE_139:Budget dev path uses Basic ACR with public network access plus Entra ID/RBAC; private endpoints require a later Premium decision.
  #checkov:skip=CKV_AZURE_163:CI already scans images with Trivy; Defender-based registry scanning is deferred until the registry is enabled and cost is accepted.
  #checkov:skip=CKV_AZURE_164:Image signing/trust policy is deferred until a real promotion path exists.
  #checkov:skip=CKV_AZURE_165:Geo-replication is a Premium/multi-region control and is not needed for the single-region dev demo.
  #checkov:skip=CKV_AZURE_166:Quarantine and verified-image workflow is deferred until image promotion exists.
  #checkov:skip=CKV_AZURE_167:Registry-side untagged manifest retention is deferred; cleanup policy belongs with the push workflow.
  #checkov:skip=CKV_AZURE_233:Zone redundancy is deferred for the single-region budget dev registry.
  #checkov:skip=CKV_AZURE_237:Dedicated data endpoints are deferred because the current ROI choice is Basic ACR, not Premium.

  name                          = var.registry_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  anonymous_pull_enabled        = var.anonymous_pull_enabled
  tags                          = var.tags
}
