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
    vultr = {
      source = "vultr/vultr"
      version = "~> 2.18.0"
    }
    minio = {
      source = "aminueza/minio"
      version = "1.18.0"
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

data "vault_generic_secret" "vultr" {
  path = "cfg/infra/tree/provider:vultr"
}

provider "vultr" {
  api_key = data.vault_generic_secret.vultr.data.key
}

data "vultr_object_storage" "bukkit" {
  filter {
    name = "label"
    values = ["bukkit"]
  }
}

provider "minio" {
  minio_server   = data.vultr_object_storage.bukkit.s3_hostname
  minio_user     = data.vultr_object_storage.bukkit.s3_access_key
  minio_password = data.vultr_object_storage.bukkit.s3_secret_key
  minio_ssl = true
}

resource "minio_s3_bucket" "bucket" {
  bucket = "bukkit"
}

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
    value = jsonencode({
      cert = "rob.mx"
      # host = "cdn.rob.mx.nyc3.digitaloceanspaces.com"
      host = data.vultr_object_storage.bukkit.s3_hostname
      bucket = "bukkit"
    })
  }
}
