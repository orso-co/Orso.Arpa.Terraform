variable "environment" {
    type = string
    description = "Name of the system or environment"
    default = "dev"
}

variable "location" {
    type = string
    description = "Azure location of terraform server environment"
    default = "Germany West Central"
}

variable "club" {
    type = string
    description = "The name of the club the installation is for"
    default = "orso"
}

variable "backendconfig" {
    description = "appsettings"
    type = object({
        logConfig = object({
            includeScopes = bool
            logLevel = object({
                default = string
                microsoft = string
                microsoftHostingLifetime = string
                microsoftEntityFrameworkCoreDatabaseCommand = string
            })
        })
        emailConfig = object({
            from = string
            smtpServer = string
            port = number
            userName = string
            password = string
            defaultSubject = string
        })
        jwtConfig = object({
            tokenKey = string
            accessTokenExpiryInMinutes = number
            refreshTokenExpiryInDays = number
        })
        identityConfig = object({
            lockoutExpiryInMinutes = number
            maxFailedLoginAttempts = number
            emailConfirmationTokenExpiryInDays = number
            dataProtectionTokenExpiryInHours = number
        })
        clubConfig = object({
            name = string
            address = string
            email = string
            phne = string
        })
  })
}   
