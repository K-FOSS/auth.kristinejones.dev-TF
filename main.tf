terraform {
  required_providers {
    #
    # Docs: https://registry.terraform.io/providers/goauthentik/authentik/latest/docs
    #
    authentik = {
      source = "goauthentik/authentik"
      version = "2021.8.4"
    }

    #
    # Hashicorp Consul
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/consul/latest/docs
    #
    consul = {
      source = "hashicorp/consul"
      version = "2.13.0"
    }
  }
}

module "Vault" {
  source = "./Vault"
}

provider "authentik" {
  url   = module.Vault.Authentik.URL
  token = module.Vault.Authentik.Token
  # Optionally set insecure to ignore TLS Certificates
  # insecure = true
}

#
# Flows
#
module "BasePasswordlessFlow" {
  source = "./Flows/BasePasswordless"
}

#
# Applications
#

module "PomeriumApp" {
  source = "./Apps/Template"

  AppName = "pomeriumproxy"

  AuthorizationFlow = module.BasePasswordlessFlow.Flow
}