terraform {
  # Optional attributes and the defaults function are
  # both experimental, so we must opt in to the experiment.
  experiments = [module_variable_optional_attrs]
}

variable "environment" {
  type        = string
  description = "Name of the system or environment"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure location of terraform server environment"
  default     = "Germany West Central"
}

variable "club" {
  type        = string
  description = "The name of the club the installation is for"
  default     = "orso"
}

variable "dbconfig" {
  description = "Settings for the postgresql db server"
  type = object({
    username     = string // ToDo: Take from key vault
    password     = string // ToDo: Take from key vault
    databaseName = string
    sku          = optional(string)
    storage      = optional(number)
  })
}

variable "backendconfig" {
  description = "appsettings"
  type = object({
    logConfig = object({
      includeScopes = bool
      logLevel = object({
        default                                     = string
        microsoft                                   = string
        microsoftHostingLifetime                    = string
        microsoftEntityFrameworkCoreDatabaseCommand = string
      })
    })
    emailConfig = object({
      from           = string
      smtpServer     = string
      port           = number
      userName       = string
      password       = string
      defaultSubject = string
    })
    jwtConfig = object({
      tokenKey                   = string
      accessTokenExpiryInMinutes = number
      refreshTokenExpiryInDays   = number
    })
    identityConfig = object({
      lockoutExpiryInMinutes             = number
      maxFailedLoginAttempts             = number
      emailConfirmationTokenExpiryInDays = number
      dataProtectionTokenExpiryInHours   = number
    })
    clubConfig = object({
      name    = string
      address = string
      email   = string
      phone   = string
    })
  })
}

locals {
  backendconfig = defaults(var.backendconfig, {
    clubConfig = {
      address = "Schwarzwaldstr. 9-11, 79117 Freiburg"
      email   = "mail@orso.co"
      name    = "ORSO – Orchestra & Choral Society Freiburg | Berlin e. V."
      phone   = "+4907617073203"
    }
    emailConfig = {
      defaultSubject = "Message from ARPA"
      from           = "arpa@orso.co"
      password       = ""          // ToDo: Take from key vault
      port           = 25          // ToDo: Take from key vault
      smtpServer     = "localhost" // ToDo: Take from key vault
      userName       = ""          // ToDo: Take from key vault
    }
    identityConfig = {
      dataProtectionTokenExpiryInHours   = 2
      emailConfirmationTokenExpiryInDays = 3
      lockoutExpiryInMinutes             = 10
      maxFailedLoginAttempts             = 3
    }
    jwtConfig = {
      accessTokenExpiryInMinutes = 10
      refreshTokenExpiryInDays   = 3
      tokenKey                   = "" // ToDo: Take from key vault
    }
    logConfig = {
      includeScopes = false
      logLevel = {
        default                                     = "Trace"
        microsoft                                   = "Warning"
        microsoftEntityFrameworkCoreDatabaseCommand = "Information"
        microsoftHostingLifetime                    = "Information"
      }
    }
  })
  dbconfig = defaults(var.dbconfig, {
    sku     = "B_Gen5_1"
    storage = 51200
  })
}

output "backendconfig" {
  value = local.backendconfig
}

output "dbconfig" {
  value = local.dbconfig
}