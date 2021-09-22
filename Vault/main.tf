terraform {
  required_providers {
    #
    # Hashicorp Vault
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/vault/latest/docs
    #
    vault = {
      source = "hashicorp/vault"
      version = "2.24.0"
    }
  }
}

# resource "vault_mount" "Terraform" {
#   path        = "Authentik"

#   type        = "kv-v2"

#   description = "Terraform Consul Sync Authentik Secrets"
# }

data "vault_generic_secret" "Authentik" {
  path = "Authentik/AUTH"
}

#
# OpenID TLS
#

locals {
  ONE_HOUR = 60 * 60

  SIX_HOURS = (60 * 60) * 6

  TWELVE_HOURS = (60 * 60) * 12

  ONE_DAY = (60 * 60) * 24

  ONE_WEEK = ((60 * 60) * 24) * 7
}

resource "vault_mount" "OpenIDRootPKI" {
  path        = "OpenIDRootPKI"

  #
  #
  #
  type        = "pki"

  description = "PKI for the ROOT CA"
  default_lease_ttl_seconds = local.ONE_DAY
  max_lease_ttl_seconds = local.ONE_WEEK
}

resource "vault_pki_secret_backend_root_cert" "OpenIDRootCA" {
  depends_on = [
    vault_mount.OpenIDRootPKI 
  ]

  backend = vault_mount.OpenIDRootPKI.path

  type = "internal"

  common_name = "Root CA"
  ttl = local.ONE_WEEK

  #
  # Formats
  #  
  
  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#format-2
  # 
  format = "pem"

  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#private_key_format-2
  #
  private_key_format = "der"

  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#key_type-2
  #
  key_type = "ec"

  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#key_bits-2
  #
  key_bits = 384
}

resource "vault_mount" "OpenIDIntPKI" {
  path        = "OpenIDIntPKI"

  type        = "pki"
  description = "PKI for the ROOT CA"

  #
  # 
  #
  default_lease_ttl_seconds = local.ONE_DAY
  max_lease_ttl_seconds = local.ONE_WEEK
}

resource "vault_pki_secret_backend_intermediate_cert_request" "OpenIDIntCA" {
  depends_on = [
    vault_mount.OpenIDRootPKI, vault_mount.OpenIDIntPKI
  ]

  backend = vault_mount.OpenIDIntPKI.path

  type = "internal"
  common_name = "pki-ca-int"

  #
  # Formats
  #  
  
  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#format-2
  # 
  format = "pem"

  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#private_key_format-2
  #
  private_key_format = "der"
  
  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#key_type-2
  #
  key_type = "ec"
  
  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#key_bits-2
  #
  key_bits = "384"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "OpenIDRootSign" {
  depends_on = [
    vault_pki_secret_backend_intermediate_cert_request.OpenIDIntCA 
  ]

  backend = vault_mount.OpenIDRootPKI.path

  csr = vault_pki_secret_backend_intermediate_cert_request.OpenIDIntCA.csr

  common_name = "pki-ca-int"

  exclude_cn_from_sans = true

  organization = "kristianjones.dev"


  #
  # TTL
  #  
  ttl = local.ONE_WEEK
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" { 
  backend = vault_mount.OpenIDIntCA.path 
  
  certificate = "${vault_pki_secret_backend_root_sign_intermediate.OpenIDRootSign.certificate}\n${vault_pki_secret_backend_root_cert.OpenIDRootCA.certificate}"
}

resource "vault_pki_secret_backend_role" "OpenIDAuthPKI" {
  backend = vault_mount.OpenIDIntPKI.path

  name    = "auth-kjdev"


  #
  # Options
  #
  generate_lease = true
  allow_any_name = true

  #
  # TTL
  #
  ttl = local.ONE_WEEK
  max_ttl = local.ONE_WEEK

  #
  # Vault Options: https://www.vaultproject.io/api/secret/pki#key_usage
  # Spec Options: https://pkg.go.dev/crypto/x509#KeyUsage
  # Authenik Orig: https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/certificate_key_pair#example-usage
  #
  key_usage = ["KeyEncipherment", "DigitalSignature"]

  #
  # Vault Options: https://www.vaultproject.io/api/secret/pki#ext_key_usage
  # Spec Options: https://pkg.go.dev/crypto/x509#ExtKeyUsage
  # Authenik Orig: https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/certificate_key_pair#example-usage
  ##
  ext_key_usage = ["ServerAuth"]
}

resource "vault_pki_secret_backend_cert" "OpenIDCert" {
  depends_on = [
    vault_pki_secret_backend_role.OpenIDIntPKI
  ]

  backend = vault_mount.OpenIDIntPKI.path
  name = vault_pki_secret_backend_role.OpenIDIntPKI.name

  common_name = "auth.kristianjones.dev"
}