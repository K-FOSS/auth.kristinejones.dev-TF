variable "AppName" {
  type = string
}

variable "AuthorizationFlow" {
  type = object({
    UUID = string
  })
}

variable "URL" {
  type = string
}

variable "Token" {
  type = string
}

variable "VaultPath" {
  type = string
}