resource "digitalocean_domain" "hidalgo_io" {
  name = "hidalgo.io"
}

resource "digitalocean_record" "a_hidalgo_io" {
  domain = digitalocean_domain.hidalgo_io.name
  type   = "A"
  name   = "@"
  value  = digitalocean_droplet.robmx.ipv4_address
}

resource "digitalocean_record" "star_hidalgo_io" {
  domain = digitalocean_domain.hidalgo_io.name
  type   = "A"
  name   = "*"
  value  = digitalocean_droplet.robmx.ipv4_address
}

resource "digitalocean_record" "spf_hidalgo_io" {
  domain = digitalocean_domain.hidalgo_io.name
  type   = "TXT"
  name   = "@"
  value  = "v=spf1 include:spf.messagingengine.com ?all"
}

resource "digitalocean_record" "mx_hidalgo_io" {
  count    = 2
  domain   = digitalocean_domain.hidalgo_io.name
  type     = "MX"
  name     = "@"
  priority = (count.index + 1) * 10
  value    = "in${count.index + 1}-smtp.messagingengine.com."
}

resource "digitalocean_record" "dkim_hidalgo_io" {
  count  = 3
  domain = digitalocean_domain.hidalgo_io.name
  type   = "CNAME"
  name   = "fm${count.index + 1}._domainkey"
  value  = "fm${count.index + 1}.hidalgo.io.dkim.fmhosted.com."
}

resource "digitalocean_record" "srv_hidalgo_io" {
  for_each = {
    smtp    = {
        record = "_submission._tcp"
        port = 587
    }
    imap    = {
        record = "_imaps._tcp"
        port = 993
    }
    pop     = {
        record = "_pop3s._tcp"
        port = 995
        priority = 10
    }
    carddav = {
        record = "_carddavs._tcp"
        port = 443
    }
    caldav  = {
        record = "_caldavs._tcp"
        port = 443
    }
  }

  domain = digitalocean_domain.hidalgo_io.name
  type   = "SRV"
  weight = 1
  priority = contains(keys(each.value), "priority") ? each.value.priority : 1
  port = each.value.port
  name   = "${each.value.record}"
  value  = "${each.key}.fastmail.com."
}
