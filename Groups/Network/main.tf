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

resource "authentik_group" "Network" {
  name         = "network_users"
  users        = [Users.KJones.id]
}