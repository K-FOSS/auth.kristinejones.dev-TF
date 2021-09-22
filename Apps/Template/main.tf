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
    # Docs: https://registry.terraform.io/providers/hashicorp/random/latest/docs
    #
    random = {
      source = "hashicorp/random"
      version = "3.1.0"
    }
  }
}


data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

resource "authentik_policy_expression" "policy" {
  name       = "example"
  expression = "return True"
}

resource "authentik_policy_binding" "app-access" {
  target = authentik_application.Application.uuid
  policy = authentik_policy_expression.policy.id
  order  = 0
}

resource "authentik_application" "Application" {
  name = var.AppName
  slug = "${var.AppName}-auth"

  protocol_provider = authentik_provider_oauth2.OID.id
}

resource "random_uuid" "ClientID" {
}

resource "random_password" "ClientSecret" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "authentik_provider_oauth2" "OID" {
  name               = var.AppName
  client_id          = random_uuid.ClientID.result
  client_secret      = random_password.ClientSecret.result
  authorization_flow = data.authentik_flow.default-authorization-flow.id
}