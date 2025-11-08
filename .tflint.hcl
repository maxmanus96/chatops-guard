plugin "azurerm" {
  enabled = true
  version = "0.29.0"                       # Pin the ruleset version for reproducible linting
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

config {
  # How TFLint calls modules:
  # - "local": lint only local modules (fast; does not require running `terraform init` in child modules)
  # - "all":   lint local + remote modules (requires `terraform init` in each module directory)
  call_module_type = "local"
}