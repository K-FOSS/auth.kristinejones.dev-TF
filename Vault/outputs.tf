output "Authentik" {
  value = {
    URL = "https://auth.kristianjones.dev:443"

    Token = data.vault_generic_secret.Authentik.data["TOKEN"]

    VaultPath = "Authentik"

    TLSCertificate = vault_pki_secret_backend_cert.OpenIDCert.certificate
    TLSKey = vault_pki_secret_backend_cert.OpenIDCert.private_key
  }
}

