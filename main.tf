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

#
# Pomerium
#

module "PomeriumApp" {
  source = "./Apps/Template"

  AppName = "pomeriumproxy"

  AuthorizationFlow = module.BasePasswordlessFlow.Flow

  VaultPath = module.Vault.Authentik.VaultPath

  OpenID = {
    URL = "https://auth.int.site1.kristianjones.dev"

    RedirectURL = "auth.int.site1aa.kristianjones.dev/oauth2/callback"
  }

  Certificate = {
    Certificate = module.Vault.Authentik.TLSCertificate
    PrivateKey = module.Vault.Authentik.TLSKey
  }
}

module "eJabberDApp" {
  source = "./Apps/Template"

  AppName = "ejabberd"

  AuthorizationFlow = module.BasePasswordlessFlow.Flow

  VaultPath = module.Vault.Authentik.VaultPath

  OpenID = {
    URL = "https://mq.kristianjones.dev"

    RedirectURL = "https://mq.kristianjones.dev"
  }

  Certificate = {
    Certificate = module.Vault.Authentik.TLSCertificate
    PrivateKey = module.Vault.Authentik.TLSKey
  }
}

#
# Hashicorp
# 

#
# Hashicorp Vault
#
