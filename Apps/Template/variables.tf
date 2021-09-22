variable "AppName" {
  type = string
}

variable "AuthorizationFlow" {
  type = object({
    UUID = string
  })
}