terraform {
  backend "consul" {
    path = "nidito/state/service/bukkit.rob.mx"
  }

  required_providers {
    consul = {
      source = "hashicorp/consul"
      version = "~> 2.18.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 4.18.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.18.0"
    }
  }

  required_version = ">= 1.0.0"
}

data "vault_generic_secret" "cf" {
  path = "cfg/infra/tree/provider:cloudflare"
}

provider "cloudflare" {
  api_token = data.vault_generic_secret.cf.data.token
}


data "terraform_remote_state" "rob_mx" {
  backend = "consul"
  workspace = "default"
  config = {
    path = "nidito/state/rob.mx"
  }
}

# TODO: page rule setting to manage existing https transport upstream
resource "cloudflare_record" "mx_rob_bukkit" {
  zone_id = data.terraform_remote_state.rob_mx.outputs.cloudflare_zone_id
  name    = "bukkit"
  value   = data.terraform_remote_state.rob_mx.outputs.bernal.ip
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "consul_keys" "cdn-config" {
  datacenter = "qro0"
  key {
    path = "cdn/bukkit.rob.mx"
    value = "rob.mx"
  }
}
