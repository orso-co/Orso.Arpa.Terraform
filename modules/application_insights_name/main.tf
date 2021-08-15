module "application_insights_name" {
  source     = "git::https://github.com/gsoft-inc/terraform-azurerm-naming"
  name       = var.name
  prefixes   = var.prefixes
  suffixes   = var.suffixes
  separator  = var.separator != null ? var.separator : "-"
  max_length = 255
}
locals {
  result = regex("^[a-zA-Z0-9-_.()]{1}[a-zA-Z0-9-_.()]*[a-zA-Z0-9-_()]$", module.application_insights_name.result)
}
