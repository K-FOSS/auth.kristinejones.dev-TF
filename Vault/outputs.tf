output "Authentik" {
  value = {
    URL = "https://auth.kristianjones.dev:8443"

    Token = data.vault_generic_secret.Authentik.data["TOKEN"]
  }
}

