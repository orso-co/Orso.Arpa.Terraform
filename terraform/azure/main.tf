terraform {
  backend "azurerm" {
    resource_group_name  = "orso-global-rg" // this has to be adapted manually if used for a different club
    storage_account_name = "orsoglobalsa"   // this has to be adapted manually if used for a different club
    container_name       = "tfstate"
  }
}

module "resource_group_name" {
  source   = "gsoft-inc/naming/azurerm//modules/general/resource_group"
  name     = "infra"
  prefixes = [var.club, "arpa", var.environment]
  suffixes = ["rg"]
}

module "app_service_plan_name" {
  source   = "../../modules/app_service_plan_name"
  name     = "infra"
  prefixes = [var.club, "arpa", var.environment]
  suffixes = ["asp"]
}

module "application_insights_name" {
  source   = "../../modules/application_insights_name"
  name     = "infra"
  prefixes = [var.club, "arpa", var.environment]
  suffixes = ["ai"]
}

module "postgresql_server_name" {
  source   = "../../modules/postgresql_server_name"
  name     = "infra"
  prefixes = [var.club, "arpa", var.environment]
  suffixes = ["pgs"]
}

module "app_service_name" {
  source   = "gsoft-inc/naming/azurerm//modules/web/web_app"
  name     = "infra"
  prefixes = [var.club, "arpa", var.environment]
  suffixes = ["as"]
}

module "storage_account_name" {
  source    = "gsoft-inc/naming/azurerm//modules/storage/storage_account"
  name      = "frontend"
  prefixes  = [var.club, "arpa", var.environment]
  separator = ""
  suffixes  = ["sa"]
}

resource "azurerm_resource_group" "arpa" {
  name     = module.resource_group_name.result
  location = var.location
}

resource "azurerm_storage_account" "arpa" {
  name                     = module.storage_account_name.result
  resource_group_name      = azurerm_resource_group.arpa.name
  location                 = azurerm_resource_group.arpa.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  static_website {
    index_document     = "index.html"
    error_404_document = "index.html"
  }

  tags = {
    environment = var.environment
  }
}

resource "azurerm_application_insights" "arpa" {
  name                = module.application_insights_name.result
  location            = azurerm_resource_group.arpa.location
  resource_group_name = azurerm_resource_group.arpa.name
  application_type    = "web"
}

resource "azurerm_app_service_plan" "arpa" {
  name                = module.app_service_plan_name.result
  location            = azurerm_resource_group.arpa.location
  resource_group_name = azurerm_resource_group.arpa.name

  sku {
    tier = "Free"
    size = "F1"
  }

  tags = {
    environment = var.environment
  }
}

resource "azurerm_postgresql_server" "arpa" {
  name                = module.postgresql_server_name.result
  location            = azurerm_resource_group.arpa.location
  resource_group_name = azurerm_resource_group.arpa.name

  administrator_login          = local.dbconfig.username
  administrator_login_password = local.dbconfig.password

  sku_name   = local.dbconfig.sku
  version    = "11"
  storage_mb = local.dbconfig.storage

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}

resource "azurerm_app_service" "arpa" {
  name                = module.app_service_name.result
  location            = azurerm_resource_group.arpa.location
  resource_group_name = azurerm_resource_group.arpa.name
  app_service_plan_id = azurerm_app_service_plan.arpa.id
  https_only          = true

  #  site_config {
  #   dotnet_framework_version = "v5.0"
  #   scm_type                 = "GitHub"
  #   http2_enabled = true
  #   health_check_path = "/health"
  #  }

  app_settings = {
    "Logging:IncludeScopes"                                           = tostring(var.backendconfig.logConfig.includeScopes)
    "Logging:LogLevel:Default"                                        = var.backendconfig.logConfig.logLevel.default
    "Logging:LogLevel:Microsoft"                                      = var.backendconfig.logConfig.logLevel.microsoft
    "Logging:LogLevel:Microsoft.Hosting.Lifetime"                     = var.backendconfig.logConfig.logLevel.microsoftHostingLifetime
    "Logging:LogLevel:Microsoft.EntityFrameworkCore.Database.Command" = var.backendconfig.logConfig.logLevel.microsoftEntityFrameworkCoreDatabaseCommand
    "EmailConfiguration:From"                                         = var.backendconfig.emailConfig.from
    "EmailConfiguration:SmtpServer"                                   = var.backendconfig.emailConfig.smtpServer
    "EmailConfiguration:Port"                                         = tostring(var.backendconfig.emailConfig.port)
    "EmailConfiguration:Username"                                     = var.backendconfig.emailConfig.userName
    "EmailConfiguration:Password"                                     = var.backendconfig.emailConfig.password
    "EmailConfiguration:DefaultSubject"                               = var.backendconfig.emailConfig.defaultSubject
    "JwtConfiguration:TokenKey"                                       = var.backendconfig.jwtConfig.tokenKey
    "JwtConfiguration:Issuer"                                         = "https://localhost:5001" // ToDo: Take from app service / custom domain
    "JwtConfiguration:Audience"                                       = "https://localhost:5001" // ToDo: Take from app service / custom domain
    "JwtConfiguration:AccessTokenExpiryInMinutes"                     = tostring(var.backendconfig.jwtConfig.accessTokenExpiryInMinutes)
    "JwtConfiguration:RefreshTokenExpiryInDays"                       = tostring(var.backendconfig.jwtConfig.refreshTokenExpiryInDays)
    "IdentityConfiguration:LockoutExpiryInMinutes"                    = tostring(var.backendconfig.identityConfig.lockoutExpiryInMinutes)
    "IdentityConfiguration:MaxFailedLoginAttempts"                    = tostring(var.backendconfig.identityConfig.maxFailedLoginAttempts)
    "IdentityConfiguration:EmailConfirmationTokenExpiryInDays"        = tostring(var.backendconfig.identityConfig.emailConfirmationTokenExpiryInDays)
    "IdentityConfiguration:DataProtectionTokenExpiryInHours"          = tostring(var.backendconfig.identityConfig.dataProtectionTokenExpiryInHours)
    "CorsConfiguration:AllowedOrigins:0"                              = azurerm_storage_account.arpa.primary_blob_endpoint
    "ClubConfiguration:Name"                                          = var.backendconfig.clubConfig.name
    "ClubConfiguration:Address"                                       = var.backendconfig.clubConfig.address
    "ClubConfiguration:Email"                                         = var.backendconfig.clubConfig.email
    "ClubConfiguration:Phone"                                         = var.backendconfig.clubConfig.phone
    "LocalizationConfiguration:DefaultCulture"                        = "en-GB"
    "LocalizationConfiguration:SupportedUiCultures:0"                 = "en"
    "LocalizationConfiguration:SupportedUiCultures:1"                 = "en-GB"
    "LocalizationConfiguration:SupportedUiCultures:2"                 = "de"
    "LocalizationConfiguration:SupportedUiCultures:3"                 = "de-DE"
    "LocalizationConfiguration:FallbackToParentCulture"               = "true"
    "APPINSIGHTS_INSTRUMENTATIONKEY"                                  = azurerm_application_insights.arpa.instrumentation_key
    "APPINSIGHTS_PROFILERFEATURE_VERSION"                             = "disabled"
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION"                             = "disabled"
    "APPLICATIONINSIGHTS_CONNECTION_STRING"                           = azurerm_application_insights.arpa.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION"                      = "~2"
    "DiagnosticServices_EXTENSION_VERSION"                            = "disabled"
    "InstrumentationEngine_EXTENSION_VERSION"                         = "disabled"
    "SnapshotDebugger_EXTENSION_VERSION"                              = "disabled"
    "XDT_MicrosoftApplicationInsights_BaseExtensions" : "disabled"
    "XDT_MicrosoftApplicationInsights_Mode" : "default"
  }

  connection_string {
    name  = "PostgreSQLConnection"
    type  = "Custom"
    value = "host=${azurerm_postgresql_server.arpa.name}.postgres.database.azure.com;port=5432;User Id=${azurerm_postgresql_server.arpa.administrator_login}@${azurerm_postgresql_server.arpa.name};password=${azurerm_postgresql_server.arpa.administrator_login_password};database=${local.dbconfig.databaseName};Ssl Mode=Require;"
  }

  tags = {
    environment = var.environment
  }
}

resource "azurerm_postgresql_firewall_rule" "arpa" {
  name                = "AppService"
  resource_group_name = azurerm_resource_group.arpa.name
  server_name         = azurerm_postgresql_server.arpa.name
  start_ip_address    = element(split(",", azurerm_app_service.arpa.outbound_ip_addresses), 0)
  end_ip_address      = element(split(",", azurerm_app_service.arpa.outbound_ip_addresses), 0)
}
