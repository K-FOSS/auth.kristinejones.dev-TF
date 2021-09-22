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
    # Docs: https://registry.terraform.io/providers/hashicorp/consul/latest/docs
    #
    consul = {
      source = "hashicorp/consul"
      version = "2.13.0"
    }

    #
    # Docs: https://registry.terraform.io/providers/hashicorp/random/latest/docs
    #
    random = {
      source = "hashicorp/random"
      version = "3.1.0"
    }

    #
    # Docs: https://registry.terraform.io/providers/hashicorp/vault/latest/docs
    #
    vault = {
      source = "hashicorp/vault"
      version = "2.24.0"
    }
  }
}

provider "consul" {
  address = "core0.site1.kristianjones.dev:8500"
}

provider "authentik" {
  url   = var.URL
  token = var.Token
  # Optionally set insecure to ignore TLS Certificates
  # insecure = true
}

resource "authentik_application" "Application" {
  name = "${var.AppName}"
  slug = "${var.AppName}-auth"
}

resource "random_uuid" "ClientID" {
}

resource "random_password" "ClientSecret" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "authentik_provider_oauth2" "OID" {
  name               = "${var.AppName}"

  #
  # Client Credentials
  #
  client_id          = "${var.AppName}-auth"
  client_secret      = random_password.ClientSecret.result

  authorization_flow = var.AuthorizationFlow.UUID
}

resource "authentik_policy_expression" "policy" {
  name       = "example"
  expression = "return True"
}

resource "authentik_policy_binding" "Application" {
  target = authentik_application.Application.uuid
  policy = authentik_policy_expression.policy.id
  order  = 0
}

resource "random_password" "VaultPath" {
  length           = 16
  special          = true
  override_special = "_%@"
}


resource "vault_generic_secret" "AppSecrets" {
  path = "authentik/apps/${var.AppName}/${random_password.VaultPath.result}"

  data_json = <<EOT
{
  "ClientID":   "${authentik_provider_oauth2.OID.client_id}",
  "ClientSecret": "${authentik_provider_oauth2.OID.client_secret}"
}
EOT
}

resource "consul_key_prefix" "ConsulData" {
  # Prefix to add to prepend to all of the subkey names below.
  path_prefix = "authentik/apps/${var.AppName}/"

  subkeys = {
    "vault_path" = "${vault_generic_secret.AppSecrets.path}"
  }
}