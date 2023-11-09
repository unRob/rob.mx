terraform {
  backend "consul" {
    path = "nidito/state/rob.mx"
  }

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.29.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "4.18.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.18.0"
    }
    vultr = {
      source = "vultr/vultr"
      version = "2.17.1"
    }
  }

  required_version = ">= 1.0.0"
}

data "vault_generic_secret" "do_token" {
  path = "cfg/infra/tree/provider:digitalocean"
}

provider "digitalocean" {
  token = data.vault_generic_secret.do_token.data.token
}

data "vault_generic_secret" "vultr" {
  path = "cfg/infra/tree/provider:vultr"
}

provider "vultr" {
  api_key = data.vault_generic_secret.vultr.data.key
}

data "vault_generic_secret" "cf" {
  path = "cfg/infra/tree/provider:cloudflare"
}

provider "cloudflare" {
  api_token = data.vault_generic_secret.cf.data.token
}
