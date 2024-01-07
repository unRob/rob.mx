terraform {
  backend "consul" {
    path = "rob.mx/state/service/cdn"
  }

  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.13.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.17.0"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.34.1"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 4.18.0"
    }
    b2 = {
      source = "Backblaze/b2"
      version = "~> 0.8.8"
    }
  }

  required_version = ">= 1.0.0"
}

data "vault_generic_secret" "backblaze" {
  path = "cfg/infra/tree/provider:backblaze"
}

data "vault_generic_secret" "digitalocean" {
  path = "cfg/infra/tree/provider:digitalocean"
}

data "vault_generic_secret" "cdn" {
  path = "cfg/infra/tree/provider:cdn"
}

data "vault_generic_secret" "cf" {
  path = "cfg/infra/tree/provider:cloudflare"
}

provider "b2" {
  application_key_id = data.vault_generic_secret.backblaze.data.key
  application_key = data.vault_generic_secret.backblaze.data.secret
}

provider "cloudflare" {
  api_token = data.vault_generic_secret.cf.data.token
}

provider "digitalocean" {
  token = data.vault_generic_secret.digitalocean.data.token
  spaces_access_id = data.vault_generic_secret.cdn.data.key
  spaces_secret_key = data.vault_generic_secret.cdn.data.secret
}

resource "digitalocean_spaces_bucket" "bucket" {
  name   = "cdn.rob.mx"
  region = "nyc3"
  acl = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://rob.mx", "https://*.rob.mx", "https://nidi.to", "https://*.nidi.to"]
    max_age_seconds = 3600
  }
}

resource "digitalocean_certificate" "cert" {
  name    = "mx.rob.cdn"
  type    = "lets_encrypt"
  domains = ["rob.mx", "cdn.rob.mx"]
}


resource "digitalocean_cdn" "cdn" {
  origin = digitalocean_spaces_bucket.bucket.bucket_domain_name
  custom_domain = "cdn.rob.mx"
  certificate_name = digitalocean_certificate.cert.name
}


resource "b2_bucket" "bucket" {
  bucket_name = "mx-rob-cdn"
  bucket_type = "allPublic"
  bucket_info = {
    "cache-control" = "max-age=3600"
  }

  cors_rules {
    cors_rule_name = "mx-rob-cdn-default"
    allowed_headers = ["*"]
    allowed_operations = [
      "s3_head",
      "s3_get",
    ]
    allowed_origins = [
      # used when locally testing shit
      "http://localhost:8080",
      "https://rob.mx",
      "https://*.rob.mx",
      "https://nidi.to",
      "https://*.nidi.to",
      "https://ruidi.to",
      "https://*.ruidi.to",
    ]
    max_age_seconds = 3600
  }

  cors_rules {
    cors_rule_name = "mx-rob-cdn-milpa"
    allowed_headers = ["*"]
    allowed_operations = [
      "s3_head",
      "s3_get",
    ]
    allowed_origins = [
      # needed for `milpa help docs --server`
      # updates need https://github.com/Backblaze/terraform-provider-b2/pull/66
      # "http://localhost:4242",
      "https://milpa.dev",
      "https://*.milpa.dev",
    ]
    max_age_seconds = 86400
  }
}


data "terraform_remote_state" "rob_mx" {
  backend = "consul"
  workspace = "default"
  config = {
    path = "nidito/state/rob.mx"
  }
}

resource "cloudflare_record" "cdn_rob_mx" {
  zone_id = data.terraform_remote_state.rob_mx.outputs.cloudflare_zone_id
  name    = "cdn"
  value   = data.terraform_remote_state.rob_mx.outputs.bernal.ip
  type    = "A"
  ttl     =  1
  proxied = true
}


data "b2_account_info" "info" {
}

resource "consul_keys" "cdn-config" {
  datacenter = "qro0"
  key {
    path = "cdn/cdn.rob.mx"
    value = jsonencode({
      cert = "rob.mx"
      proxy = "dns"
      host = replace(data.b2_account_info.info.s3_api_url, "https://", "")
      bucket = b2_bucket.bucket.bucket_name
    })
  }
}
