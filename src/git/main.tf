terraform {
  backend "consul" {
    datacenter = "nyc1"
    path = "rob.mx/state/service/git"
  }

  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.16.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.7.0"
    }
  }

  required_version = ">= 1.0.0"
}

data "vault_generic_secret" "do" {
  path = "cfg/infra/tree/provider:digitalocean"
}

provider "digitalocean" {
  token = data.vault_generic_secret.do.data.token
}

data "digitalocean_droplet" "bedstuy" {
  name = "bedstuy"
}

locals {
  policies = {
    "sys/capabilities-self" = ["update"]
    "auth/token/renew-self" = ["update"]
    "config/kv/service:git" = ["read"]
    "config/kv/provider:cdn" = ["read"]
    "cfg/svc/tree/rob.mx:git" = ["read"]
    "cfg/infra/tree/provider:cdn" = ["read"]
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

resource "digitalocean_record" "cname" {
  domain = "rob.mx"
  type   = "A"
  name   = "git"
  ttl    = 3600
  value  = data.digitalocean_droplet.bedstuy.ipv4_address
}

resource "digitalocean_record" "txt_smtp_domainkey" {
  domain = "rob.mx"
  type   = "TXT"
  name   = "mailo._domainkey.git"
  value  = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDkDsQqliBiOUy1nD6DpFHQ8V8GJ8j0lRCkBWanShFnlkm2qVmT1oJur7bV0sXulAlWvAVLztW6Dh3vc7v1R0Y8GzlrSSYz+eJx9ebl4o+Bxn7yQkC53f7OZmMQU1sq7wOyxZnoXDOB0Di/b41GsYc70c4qrsxb30IR0uDlG5CV1wIDAQAB"
}

resource "digitalocean_record" "txt_spf" {
  domain = "rob.mx"
  type   = "TXT"
  name   = "git"
  value  = "v=spf1 include:mailgun.org ~all;"
}


resource "digitalocean_record" "mx_git" {
  for_each = {
    "mxa.mailgun.org." = 10,
    "mxb.mailgun.org." = 10,
  }
  domain   = "rob.mx"
  type     = "MX"
  name     = "git"
  value    = each.key
  priority = each.value
}
