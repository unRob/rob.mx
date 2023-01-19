terraform {
  backend "consul" {
    datacenter = "nyc1"
    path = "nidito/state/service/bukkit.rob.mx"
  }

  required_providers {
    consul = {
      source = "hashicorp/consul"
      version = "~> 2.16.2"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.22.3"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.8.2"
    }
  }

  required_version = ">= 1.0.0"
}


data "vault_generic_secret" "do" {
  path = "cfg/infra/provider:digitalocean"
}

provider "digitalocean" {
  token = data.vault_generic_secret.do.data.token
}

data "digitalocean_droplet" "bedstuy" {
  name = "bedstuy"
}

resource "digitalocean_record" "mx_rob_bukkit" {
  domain = "rob.mx"
  type   = "A"
  ttl    = 3600
  name   = "bukkit"
  value  = data.digitalocean_droplet.bedstuy.ipv4_address
}

resource "consul_keys" "cdn-config" {
  datacenter = "nyc1"
  key {
    path = "cdn/bukkit.rob.mx"
    value = "rob.mx"
  }
}
