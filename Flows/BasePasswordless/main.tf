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

resource "authentik_stage_identification" "UserIdentification" {
  name           = "person-ident"
  user_fields    = ["username", "email"]
}

resource "authentik_stage_authenticator_webauthn" "Passwordless" {
  name = "basewebauthn-passwordless-core"
}

resource "authentik_flow" "Flow" {
  name        = "webauthn-passwordless-flow"
  title       = "Base WebAuthn Passwordless flow"
  slug        = "passwordless-flow"
  designation = "authorization"
}

resource "authentik_flow_stage_binding" "UserIdentification" {
  target = authentik_flow.Flow.uuid

  stage  = authentik_stage_identification.UserIdentification.id
  order  = 0
}

resource "authentik_flow_stage_binding" "WebAuthnBinding" {
  target = authentik_flow.Flow.uuid
  stage  = authentik_stage_authenticator_webauthn.Passwordless.id
  order  = 10
}