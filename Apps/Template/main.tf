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

provider "authentik" {
  url   = var.URL
  token = var.Token
  # Optionally set insecure to ignore TLS Certificates
  # insecure = true
}


resource "authentik_stage_authenticator_webauthn" "Passwordless" {
  name = "webauthn-core"
}

resource "authentik_flow" "flow" {
  name        = "test-flow"
  title       = "Test flow"
  slug        = "test-flow"
  designation = "authorization"
}

resource "authentik_flow_stage_binding" "dummy-flow" {
  target = authentik_flow.flow.uuid
  stage  = authentik_stage_authenticator_webauthn.Passwordless.id
  order  = 0
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
  client_id          = "${var.AppName}-auth"
  client_secret      = random_password.ClientSecret.result
  authorization_flow = authentik_flow.flow.uuid
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