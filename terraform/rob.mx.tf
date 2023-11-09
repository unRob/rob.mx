resource "cloudflare_zone" "rob_mx" {
  zone = "rob.mx"
  account_id = nonsensitive(data.vault_generic_secret.cf.data.account)
}

output "cloudflare_zone_id" {
  value = cloudflare_zone.rob_mx.id
}

resource "cloudflare_record" "rob_mx" {
  zone_id = cloudflare_zone.rob_mx.id
  name    = "rob.mx"
  value   = digitalocean_droplet.robmx.ipv4_address
  type    = "A"
  # ttl     = 1800
}

resource "cloudflare_record" "star_rob_mx" {
  zone_id = cloudflare_zone.rob_mx.id
  name    = "*"
  value   = digitalocean_droplet.robmx.ipv4_address
  type    = "A"
  # ttl     = 1800
}

resource "cloudflare_record" "spf_rob_mx" {
  zone_id = cloudflare_zone.rob_mx.id
  type   = "TXT"
  name   = "rob.mx"
  value  = "\"v=spf1 include:spf.messagingengine.com ?all\""
}

resource "cloudflare_record" "mx_rob_mx" {
  count    = 2
  zone_id = cloudflare_zone.rob_mx.id
  type     = "MX"
  name     = "rob.mx"
  priority = (count.index + 1) * 10
  value    = "in${count.index + 1}-smtp.messagingengine.com."
}

resource "cloudflare_record" "mx_star_rob_mx" {
  count    = 2
  zone_id = cloudflare_zone.rob_mx.id
  type     = "MX"
  name     = "*"
  priority = (count.index + 1) * 10
  value    = "in${count.index + 1}-smtp.messagingengine.com."
}

resource "cloudflare_record" "dkim_rob_mx" {
  count  = 3
  zone_id = cloudflare_zone.rob_mx.id
  type   = "CNAME"
  name   = "fm${count.index + 1}._domainkey"
  value  = "fm${count.index + 1}.rob.mx.dkim.fmhosted.com."
}

resource "cloudflare_record" "srv_rob_mx" {
  for_each = {
    smtp    = {
        record = "_submission"
        port = 587
    }
    imap    = {
        record = "_imaps"
        port = 993
    }
    jmap    = {
        record = "_jmap"
        port = 993
    }
    pop     = {
        record = "_pop3s"
        port = 995
        priority = 10
    }
    carddav = {
        record = "_carddavs"
        port = 443
    }
    caldav  = {
        record = "_caldavs"
        port = 443
    }
  }

  zone_id = cloudflare_zone.rob_mx.id
  type   = "SRV"
  name   = "${each.value.record}._tcp"
  data {
    name = "rob.mx"
    service   = "${each.value.record}"
    proto = "_tcp"
    weight = 1
    priority = contains(keys(each.value), "priority") ? each.value.priority : 1
    port = each.value.port
    target  = "${each.key}.fastmail.com"
  }
}


resource "digitalocean_domain" "rob_mx" {
  name = "rob.mx"
}
