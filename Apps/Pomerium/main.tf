terraform {
  required_providers {
    #
    # Docs: https://registry.terraform.io/providers/goauthentik/authentik/latest/docs
    #
    authentik = {
      source = "goauthentik/authentik"
      version = "2021.8.4"
    }
  }
}


data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

resource "authentik_provider_oauth2" "name" {
  name               = "example-app"
  client_id          = "example-app"
  client_secret      = "test"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
}

resource "authentik_policy_expression" "policy" {
  name       = "example"
  expression = "return True"
}

resource "authentik_policy_binding" "app-access" {
  target = authentik_application.name.id
  policy = authentik_policy_expression.policy.id
  order  = 0
}

resource "authentik_application" "name" {
  name = "example-app"
  slug = "example-app"
}