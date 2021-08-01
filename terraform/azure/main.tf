terraform {
  backend "azurerm" {
    resource_group_name  = "orso-global-rg" // this has to be adapted manually if used for a different club
    storage_account_name = "orsoglobalsa" // this has to be adapted manually if used for a different club
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

module "app_service_name" {
  source   = "gsoft-inc/naming/azurerm//modules/web/web_app"
  name     = "infra"
  prefixes = [var.club, "arpa", var.environment]
  suffixes = ["as"]
}

module "storage_account_name" {
  source   = "gsoft-inc/naming/azurerm//modules/storage/storage_account"
  name     = "frontend"
  prefixes = [var.club, "arpa", var.environment]
  separator = ""
  suffixes = ["sa"]
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
    index_document = "index.html"
    error_404_document = "index.html"
  }

  tags = {
    environment = var.environment
  }
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

resource "azurerm_app_service" "arpa" {
  name                = module.app_service_name.result
  location            = azurerm_resource_group.arpa.location
  resource_group_name = azurerm_resource_group.arpa.name
  app_service_plan_id = azurerm_app_service_plan.arpa.id
  https_only = true

  site_config {
    dotnet_framework_version = "v5.0"
    scm_type                 = "GitHub"
    http2_enabled = true
    health_check_path = "/health"
  }

  app_settings = {
    "Logging:IncludeScopes" = tostring(var.backendconfig.logConfig.includeScopes)
    "Logging:LogLevel:Default" = var.backendconfig.logConfig.logLevel.default
    "Logging:LogLevel:Microsoft" = var.backendconfig.logConfig.logLevel.microsoft
    "Logging:LogLevel:Microsoft.Hosting.Lifetime" = var.backendconfig.logConfig.logLevel.microsoftHostingLifetime
    "Logging:LogLevel:Microsoft.EntityFrameworkCore.Database.Command" = var.backendconfig.logConfig.logLevel.microsoftEntityFrameworkCoreDatabaseCommand
    "EmailConfiguration:From" = var.backendconfig.emailConfig.from
    "EmailConfiguration:SmtpServer" = var.backendconfig.emailConfig.smtpServer
    "EmailConfiguration:Port" = tostring(var.backendconfig.emailConfig.port)
    "EmailConfiguration:Username" = var.backendconfig.emailConfig.userName
    "EmailConfiguration:Password" = var.backendconfig.emailConfig.password
    "EmailConfiguration:DefaultSubject" = var.backendconfig.emailConfig.defaultSubject
    "JwtConfiguration:TokenKey" = var.backendconfig.jwtConfig.tokenKey
    "JwtConfiguration:Issuer" = "https://localhost:5001" // ToDo: Take from app service / custom domain
    "JwtConfiguration:Audience" = "https://localhost:5001" // ToDo: Take from app service / custom domain
    "JwtConfiguration:AccessTokenExpiryInMinutes" = var.backendconfig.jwtConfig.accessTokenExpiryInMinutes
    "JwtConfiguration:RefreshTokenExpiryInDays" = var.backendconfig.jwtConfig.refreshTokenExpiryInDays
    "IdentityConfiguration:LockoutExpiryInMinutes" = var.backendconfig.identityConfig.lockoutExpiryInMinutes
    "IdentityConfiguration:MaxFailedLoginAttempts" = var.backendconfig.identityConfig.maxFailedLoginAttempts
    "IdentityConfiguration:EmailConfirmationTokenExpiryInDays" = var.backendconfig.identityConfig.emailConfirmationTokenExpiryInDays
    "IdentityConfiguration:DataProtectionTokenExpiryInHours" = var.backendconfig.identityConfig.dataProtectionTokenExpiryInHours
    "CorsConfiguration:AllowedOrigins:0" = azurerm_storage_account.arpa.primary_blob_endpoint
    "ClubConfiguration:Name" = var.backendconfig.clubConfig.name
    "ClubConfiguration:Address" = var.backendconfig.clubConfig.address
    "ClubConfiguration:Email" = var.backendconfig.clubConfig.email
    "ClubConfiguration:Phone" = var.backendconfig.clubConfig.phone
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
    environment = var.environment
  }
}
