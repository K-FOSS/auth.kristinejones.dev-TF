variable "AppName" {
  type = string
}

variable "OpenID" {
  value = object({
    URL = string

    RedirectURL = any
  })

  default = {
    URL = "https://auth.kristianjones.dev"
  }
}

variable "AuthorizationFlow" {
  type = object({
    UUID = string
  })
}

variable "VaultPath" {
  type = string
}