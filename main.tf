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
# Users
# 

module "Users" {
  source = "./Users"
}

#
# Groups
#

module "NetworkGroup" {
  source = "./Groups/Network"

  Users = module.Users
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

  URL   = module.Vault.Authentik.URL
  Token = module.Vault.Authentik.Token
}