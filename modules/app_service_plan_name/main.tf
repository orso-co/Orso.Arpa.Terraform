module "app_service_plan_name" {
  source     = "git::https://github.com/gsoft-inc/terraform-azurerm-naming"
  name       = var.name
  prefixes   = var.prefixes
  suffixes   = var.suffixes
  separator  = var.separator != null ? var.separator : "-"
  max_length = 40
}
locals {
  result = regex("^[a-zA-Z0-9]{1}[a-zA-Z0-9-]*$", module.app_service_plan_name.result)
}
