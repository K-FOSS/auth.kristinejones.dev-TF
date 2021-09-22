variable "AppName" {
  type = string
}

variable "OpenID" {
  type = object({
    URL = string

    RedirectURL = any
  })

  default = {
    URL = "https://auth.kristianjones.dev"

    RedirectURL = null
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

variable "Certificate" {
  type = object({
    Certificate = string

    PrivateKey = string
  })

  sensitive = true
}