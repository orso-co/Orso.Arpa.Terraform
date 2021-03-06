## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | <3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 2.68.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_service_name"></a> [app\_service\_name](#module\_app\_service\_name) | gsoft-inc/naming/azurerm//modules/web/web_app | n/a |
| <a name="module_app_service_plan_name"></a> [app\_service\_plan\_name](#module\_app\_service\_plan\_name) | ../../modules/app_service_plan_name | n/a |
| <a name="module_application_insights_name"></a> [application\_insights\_name](#module\_application\_insights\_name) | ../../modules/application_insights_name | n/a |
| <a name="module_postgresql_server_name"></a> [postgresql\_server\_name](#module\_postgresql\_server\_name) | ../../modules/postgresql_server_name | n/a |
| <a name="module_resource_group_name"></a> [resource\_group\_name](#module\_resource\_group\_name) | gsoft-inc/naming/azurerm//modules/general/resource_group | n/a |
| <a name="module_storage_account_name"></a> [storage\_account\_name](#module\_storage\_account\_name) | gsoft-inc/naming/azurerm//modules/storage/storage_account | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_app_service.arpa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service) | resource |
| [azurerm_app_service_plan.arpa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_plan) | resource |
| [azurerm_application_insights.arpa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_postgresql_firewall_rule.arpa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_firewall_rule) | resource |
| [azurerm_postgresql_server.arpa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_server) | resource |
| [azurerm_resource_group.arpa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_storage_account.arpa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backendconfig"></a> [backendconfig](#input\_backendconfig) | appsettings | <pre>object({<br>    logConfig = object({<br>      includeScopes = bool<br>      logLevel = object({<br>        default                                     = string<br>        microsoft                                   = string<br>        microsoftHostingLifetime                    = string<br>        microsoftEntityFrameworkCoreDatabaseCommand = string<br>      })<br>    })<br>    emailConfig = object({<br>      from           = string<br>      smtpServer     = string<br>      port           = number<br>      userName       = string<br>      password       = string<br>      defaultSubject = string<br>    })<br>    jwtConfig = object({<br>      tokenKey                   = string<br>      accessTokenExpiryInMinutes = number<br>      refreshTokenExpiryInDays   = number<br>    })<br>    identityConfig = object({<br>      lockoutExpiryInMinutes             = number<br>      maxFailedLoginAttempts             = number<br>      emailConfirmationTokenExpiryInDays = number<br>      dataProtectionTokenExpiryInHours   = number<br>    })<br>    clubConfig = object({<br>      name    = string<br>      address = string<br>      email   = string<br>      phone   = string<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_club"></a> [club](#input\_club) | The name of the club the installation is for | `string` | `"orso"` | no |
| <a name="input_dbconfig"></a> [dbconfig](#input\_dbconfig) | Settings for the postgresql db server | <pre>object({<br>    username     = string // ToDo: Take from key vault<br>    password     = string // ToDo: Take from key vault<br>    sku          = string<br>    storage      = number<br>    databaseName = string<br>  })</pre> | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the system or environment | `string` | `"dev"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure location of terraform server environment | `string` | `"Germany West Central"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backendconfig"></a> [backendconfig](#output\_backendconfig) | n/a |
| <a name="output_dbconfig"></a> [dbconfig](#output\_dbconfig) | n/a |
