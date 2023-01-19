resource "digitalocean_domain" "unrob_com" {
  name = "unrob.com"
}

resource "digitalocean_record" "a_unrob_com" {
  domain = digitalocean_domain.unrob_com.name
  type   = "A"
  name   = "@"
  value  = digitalocean_droplet.robmx.ipv4_address
}

resource "digitalocean_record" "star_unrob_com" {
  domain = digitalocean_domain.unrob_com.name
  type   = "A"
  name   = "*"
  value  = digitalocean_droplet.robmx.ipv4_address
}

resource "digitalocean_record" "spf_unrob_com" {
  domain = digitalocean_domain.unrob_com.name
  type   = "TXT"
  name   = "@"
  value  = "v=spf1 include:spf.messagingengine.com ?all"
}

resource "digitalocean_record" "mx_unrob_com" {
  count    = 2
  domain   = digitalocean_domain.unrob_com.name
  type     = "MX"
  name     = "@"
  priority = (count.index + 1) * 10
  value    = "in${count.index + 1}-smtp.messagingengine.com."
}

resource "digitalocean_record" "mx_star_unrob_com" {
  count    = 2
  domain   = digitalocean_domain.unrob_com.name
  type     = "MX"
  name     = "*"
  priority = (count.index + 1) * 10
  value    = "in${count.index + 1}-smtp.messagingengine.com."
}

resource "digitalocean_record" "dkim_unrob_com" {
  count  = 3
  domain = digitalocean_domain.unrob_com.name
  type   = "CNAME"
  name   = "fm${count.index + 1}._domainkey"
  value  = "fm${count.index + 1}.unrob.com.dkim.fmhosted.com."
}

resource "digitalocean_record" "srv_unrob_com" {
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

  domain = digitalocean_domain.unrob_com.name
  type   = "SRV"
  weight = 1
  priority = contains(keys(each.value), "priority") ? each.value.priority : 1
  port = each.value.port
  name   = "${each.value.record}"
  value  = "${each.key}.fastmail.com."
}
