terraform {
  required_providers {
    #
    # Hashicorp Vault
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/vault/latest/docs
    #
    vault = {
      source = "hashicorp/vault"
      version = "2.22.1"
    }
  }
}

resource "vault_mount" "Terraform" {
  path        = "Authentik"

  type        = "kv-v2"

  description = "Terraform Consul Sync Authentik Secrets"
}

data "vault_generic_secret" "Authentik" {
  path = "${vault_mount.Terraform.path}/AUTH"
}

