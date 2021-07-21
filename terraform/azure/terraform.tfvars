environment = "dev"
location = "Germany West Central"
club = "orso"
backendconfig = {
  clubConfig = {
    address = "Schwarzwaldstr. 9-11, 79117 Freiburg"
    email = "mail@orso.co"
    name = "ORSO – Orchestra & Choral Society Freiburg | Berlin e. V."
    phne = "+4907617073203"
  }
  emailConfig = {
    defaultSubject = "Message from ARPA"
    from = "arpa@orso.co"
    password = "" // ToDo: Take from key vault
    port = 25 // ToDo: Take from key vault
    smtpServer = "localhost" // ToDo: Take from key vault
    userName = "" // ToDo: Take from key vault
  }
  identityConfig = {
    dataProtectionTokenExpiryInHours = 2
    emailConfirmationTokenExpiryInDays = 3
    lockoutExpiryInMinutes = 10
    maxFailedLoginAttempts = 3
  }
  jwtConfig = {
    accessTokenExpiryInMinutes = 10
    refreshTokenExpiryInDays = 3
    tokenKey = "" // ToDo: Take from key vault
  }
  logConfig = {
    includeScopes = false
    logLevel = {
      default = "Trace"
      microsoft = "Warning"
      microsoftEntityFrameworkCoreDatabaseCommand = "Information"
      microsoftHostingLifetime = "Information"
    }
  }
}
