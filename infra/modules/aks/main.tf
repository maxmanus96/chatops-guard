resource "azurerm_kubernetes_cluster" "this" {
  #checkov:skip=CKV_AZURE_115: Private cluster is deferred until a VNet-connected admin or runner path exists for this repo.
  #checkov:skip=CKV_AZURE_117: Disk encryption set depends on Key Vault and customer-managed key lifecycle, which is deferred to the Key Vault integration slice.
  #checkov:skip=CKV_AZURE_170: Paid SKU is intentionally deferred while the AKS module remains demo-focused and unapplied.
  #checkov:skip=CKV_AZURE_172: Secrets Store CSI autorotation will be enabled with the Key Vault integration slice, not in the pre-Key Vault skeleton.
  #checkov:skip=CKV_AZURE_226: Ephemeral OS disks are deferred until the real node VM size is chosen because support depends on the selected VM family.
  #checkov:skip=CKV_AZURE_227: Host encryption is deferred until the real node VM size and first-cluster shape are fixed.
  #checkov:skip=CKV_AZURE_232: only_critical_addons_enabled is deferred until a separate user node pool exists; enabling it now would strand non-critical workloads on the only pool.
  name                      = var.cluster_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  dns_prefix                = var.dns_prefix
  kubernetes_version        = var.kubernetes_version
  sku_tier                  = var.sku_tier
  azure_policy_enabled      = true
  local_account_disabled    = var.local_account_disabled
  private_cluster_enabled   = var.private_cluster_enabled
  automatic_upgrade_channel = var.automatic_upgrade_channel

  # Keep the first module version intentionally small.
  # Enable the lowest-friction security defaults now; defer networking and cost-bearing hardening to later tickets.
  # For the demo path, keep the API server public but optionally restrict it to known admin IPs.
  dynamic "api_server_access_profile" {
    for_each = length(var.api_server_authorized_ip_ranges) > 0 ? [1] : []

    content {
      authorized_ip_ranges = var.api_server_authorized_ip_ranges
    }
  }

  # Keep one mixed system pool for now. Restricting this pool to only critical addons
  # would require a separate user pool first, which is a later slice for this module.
  default_node_pool {
    name           = "system"
    node_count     = var.node_count
    vm_size        = var.node_vm_size
    max_pods       = 50
    vnet_subnet_id = var.vnet_subnet_id

    # Make the provider/Azure defaults explicit so the first applied cluster
    # does not keep showing an in-place node pool diff on the next plan.
    upgrade_settings {
      max_surge                     = "10%"
      drain_timeout_in_minutes      = 0
      node_soak_duration_in_minutes = 0
    }
  }

  network_profile {
    network_plugin      = var.network_plugin
    network_plugin_mode = var.network_plugin_mode
    network_policy      = var.network_policy
    network_data_plane  = var.network_data_plane
    outbound_type       = var.outbound_type
    load_balancer_sku   = "standard"
  }

  oms_agent {
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    msi_auth_for_monitoring_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
