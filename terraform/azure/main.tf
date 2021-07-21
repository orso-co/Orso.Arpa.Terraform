terraform {
  backend "azurerm" {
    resource_group_name  = "orso-global-rg"
    storage_account_name = "orsoglobalsa"
    container_name       = "tfstate"
  }
}

module "resource_group_name" {
  source   = "gsoft-inc/naming/azurerm//modules/general/resource_group"
  name     = "infra"
  prefixes = ["orso", "arpa", "dev"]
  suffixes = ["rg"]
}

module "app_service_plan_name" {
  source   = "../../modules/app_service_plan_name"
  name     = "infra"
  prefixes = ["orso", "arpa", "dev"]
  suffixes = ["asp"]
}

module "app_service_name" {
  source   = "gsoft-inc/naming/azurerm//modules/web/web_app"
  name     = "infra"
  prefixes = ["orso", "arpa", "dev"]
  suffixes = ["as"]
}

module "storage_account_name" {
  source   = "gsoft-inc/naming/azurerm//modules/storage/storage_account"
  name     = "frontend"
  prefixes = ["orso", "arpa", "dev"]
  separator = ""
  suffixes = ["sa"]
}

resource "azurerm_resource_group" "orsoarpadev" {
  name     = module.resource_group_name.result
  location = "Germany West Central"
}

resource "azurerm_storage_account" "orsoarpadev" {
  name                     = module.storage_account_name.result
  resource_group_name      = azurerm_resource_group.orsoarpadev.name
  location                 = azurerm_resource_group.orsoarpadev.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  static_website {
    index_document = "index.html"
    error_404_document = "index.html"
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_app_service_plan" "orsoarpadev" {
  name                = module.app_service_plan_name.result
  location            = azurerm_resource_group.orsoarpadev.location
  resource_group_name = azurerm_resource_group.orsoarpadev.name

  sku {
    tier = "Free"
    size = "F1"
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_app_service" "orsoarpadev" {
  name                = module.app_service_name.result
  location            = azurerm_resource_group.orsoarpadev.location
  resource_group_name = azurerm_resource_group.orsoarpadev.name
  app_service_plan_id = azurerm_app_service_plan.orsoarpadev.id
  https_only = true

  site_config {
    dotnet_framework_version = "v5.0"
    scm_type                 = "GitHub"
    http2_enabled = true
    health_check_path = "/health"
  }

  app_settings = {
    "Logging:IncludeScopes" = "false"
    "Logging:LogLevel:Default" = "Trace"
    "Logging:LogLevel:Microsoft" = "Warning"
    "Logging:LogLevel:Microsoft.Hosting.Lifetime" = "Information"
    "Logging:LogLevel:Microsoft.EntityFrameworkCore.Database.Command" = "Information"
    "EmailConfiguration:From" = "dev@arpa.orso.co"
    "EmailConfiguration:SmtpServer" = "localhost"
    "EmailConfiguration:Port" = "25"
    "EmailConfiguration:Username" = ""
    "EmailConfiguration:Password" = ""
    "EmailConfiguration:DefaultSubject" = "Message from ARPA"
    "JwtConfiguration:TokenKey" = ""
    "JwtConfiguration:Issuer" = "https://localhost:5001"
    "JwtConfiguration:Audience" = "https://localhost:5001"
    "JwtConfiguration:AccessTokenExpiryInMinutes" = "10"
    "JwtConfiguration:RefreshTokenExpiryInDays" = "3"
    "IdentityConfiguration:LockoutExpiryInMinutes" = "10"
    "IdentityConfiguration:MaxFailedLoginAttempts" = "3"
    "IdentityConfiguration:EmailConfirmationTokenExpiryInDays" = "3"
    "IdentityConfiguration:DataProtectionTokenExpiryInHours" = "2"
    "CorsConfiguration:AllowedOrigins:0" = "http://localhost:4200" // ToDo: Add storage url
    "ClubConfiguration:Name" = "ORSO – Orchestra & Choral Society Freiburg | Berlin e. V."
    "ClubConfiguration:Address" = "Schwarzwaldstr. 9-11, 79117 Freiburg"
    "ClubConfiguration:Email" = "mail@orso.co"
    "ClubConfiguration:Phone" = "+4907617073203"
    "LocalizationConfiguration:DefaultCulture" = "en-GB"
    "LocalizationConfiguration:SupportedUiCultures:0" = "en"
    "LocalizationConfiguration:SupportedUiCultures:1" = "en-GB"
    "LocalizationConfiguration:SupportedUiCultures:2" = "de"
    "LocalizationConfiguration:SupportedUiCultures:3" = "de-DE"
    "LocalizationConfiguration:FallbackToParentCulture" = "true"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = "" // ToDo: Take from app insights resource
    "APPINSIGHTS_PROFILERFEATURE_VERSION" = "disabled"
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION" = "disabled"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" ="InstrumentationKey=" // ToDo: Take from app insights resource
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~2"
    "DiagnosticServices_EXTENSION_VERSION" = "disabled"
    "InstrumentationEngine_EXTENSION_VERSION" = "disabled"
    "SnapshotDebugger_EXTENSION_VERSION" = "disabled"
    "XDT_MicrosoftApplicationInsights_BaseExtensions": "disabled"
    "XDT_MicrosoftApplicationInsights_Mode": "default"
  }

  connection_string {
    name  = "PostgreSQLConnection"
    type  = "Custom"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI" // ToDo: Take from postgreSQL resource
  }

  tags = {
    environment = "dev"
  }

  logs {
    detailed_error_messages_enabled = true
    failed_request_tracing_enabled = true
    application_logs {
        azure_blob_storage {
            sas_url = "" // ToDo: Take from blob storage resource
            retention_in_days = 3
            level = "Warning"
        }
    }
    http_logs {
        azure_blob_storage {
            sas_url = "" // ToDo: Take from blob storage resource
            retention_in_days = 3
        }
    }
  }
}
