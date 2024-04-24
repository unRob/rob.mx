terraform {
  backend "consul" {
    datacenter = "qro0"
    path = "rob.mx/state/service/git"
  }

  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.36.0"
    }

    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 4.30.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.2.0"
    }

    vultr = {
      source = "vultr/vultr"
      version = "~> 2.19.0"
    }

    minio = {
      source = "aminueza/minio"
      version = "~> 2.0.0"
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


data "vault_generic_secret" "do" {
  path = "cfg/infra/tree/provider:digitalocean"
}

data "vault_generic_secret" "vultr" {
  path = "cfg/infra/tree/provider:vultr"
}

provider "digitalocean" {
  token = data.vault_generic_secret.do.data.token
}

provider "vultr" {
  api_key = data.vault_generic_secret.vultr.data.key
}

locals {
  policies = {
    "sys/capabilities-self" = ["update"]
    "auth/token/renew-self" = ["update"]
    "cfg/svc/tree/rob.mx:git" = ["read"]
  }
}

resource "vault_policy" "service" {
  name = "git-rob-mx"
  policy = <<-HCL
  %{ for path in sort(keys(local.policies)) }path "${path}" {
    capabilities = ${jsonencode(local.policies[path])}
  }

  %{ endfor }
  HCL
}

resource "vault_jwt_auth_backend_role" "service" {
  backend = "nomad-workload"
  role_type = "jwt"
  role_name = "git-rob-mx"
  bound_audiences = ["vault.io"]
  user_claim = "/nomad_job_id"
  user_claim_json_pointer = true
  claim_mappings = {
    nomad_namespace = "nomad_namespace"
    nomad_job_id = "nomad_job_id"
    nomad_task = "nomad_task"
  }
  token_type = "service"
  token_policies = [vault_policy.service.name]
  token_period = 60 * 60 * 6
  token_explicit_max_ttl = 0
}


resource "cloudflare_record" "git" {
  zone_id = data.terraform_remote_state.rob_mx.outputs.cloudflare_zone_id
  type   = "A"
  name   = "git"
  ttl    = 3600
  value  = data.terraform_remote_state.rob_mx.outputs.bernal.ip
}

resource "cloudflare_record" "txt_smtp_domainkey" {
  zone_id = data.terraform_remote_state.rob_mx.outputs.cloudflare_zone_id
  type   = "TXT"
  name   = "mailo._domainkey.git"
  value  = "\"k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDkDsQqliBiOUy1nD6DpFHQ8V8GJ8j0lRCkBWanShFnlkm2qVmT1oJur7bV0sXulAlWvAVLztW6Dh3vc7v1R0Y8GzlrSSYz+eJx9ebl4o+Bxn7yQkC53f7OZmMQU1sq7wOyxZnoXDOB0Di/b41GsYc70c4qrsxb30IR0uDlG5CV1wIDAQAB\""
}

resource "cloudflare_record" "txt_spf" {
  zone_id = data.terraform_remote_state.rob_mx.outputs.cloudflare_zone_id
  type   = "TXT"
  name   = "git"
  value  = "\"v=spf1 include:mailgun.org ~all;\""
}

resource "cloudflare_record" "mx_git" {
  zone_id = data.terraform_remote_state.rob_mx.outputs.cloudflare_zone_id
  for_each = {
    "mxa.mailgun.org" = 10,
    "mxb.mailgun.org" = 10,
  }
  type     = "MX"
  name     = "git"
  value    = each.key
  priority = each.value
}

data "vultr_object_storage" "bukkit" {
  filter {
    name = "label"
    values = ["bukkit"]
  }
}

# https://github.com/vultr/terraform-provider-vultr/issues/55
# sigh
provider "minio" {
  minio_server   = data.vultr_object_storage.bukkit.s3_hostname
  minio_user     = data.vultr_object_storage.bukkit.s3_access_key
  minio_password = data.vultr_object_storage.bukkit.s3_secret_key
  minio_ssl = true
}

resource "minio_s3_bucket" "git" {
  bucket = "git"
}

