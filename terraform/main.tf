terraform {
  backend "consul" {
    path = "nidito/state/rob.mx"
  }

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.16.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.7.0"
    }
  }

  required_version = ">= 1.0.0"
}

data "vault_generic_secret" "do_token" {
  path = "cfg/infra/tree/provider:digitalocean"
}

provider "digitalocean" {
  token = data.vault_generic_secret.do_token.data["token"]
}
