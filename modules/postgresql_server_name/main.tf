module "postgresql_server_name" {
  source     = "git::https://github.com/gsoft-inc/terraform-azurerm-naming"
  name       = var.name
  prefixes   = var.prefixes
  suffixes   = var.suffixes
  separator  = var.separator != null ? var.separator : "-"
  max_length = 63
}
locals {
  result = regex("^[a-z0-9]{1}[a-z0-9-]{2}[a-zA-Z0-9-]*[a-z0-9]$", module.postgresql_server_name.result)
}
