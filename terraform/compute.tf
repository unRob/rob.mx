resource "digitalocean_droplet" "robmx" {
  image  = "6918990"
  name   = "rob.mx"
  region = "sfo1"
  size   = "1gb"
}

resource "digitalocean_record" "sfo0_tepetl_net" {
  domain = "tepetl.net"
  type = "A"
  name = "sfo0"
  value = digitalocean_droplet.robmx.ipv4_address
}

resource "vultr_ssh_key" "public" {
  name = "personal"
  ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMgRfvmvP4uyefJIH1rmecOUz1r+iNdCIvJv3M14RAnt"
}

resource "vultr_vpc2" "qro0" {
  description = "qro0"
  region = "mex"
  ip_block = "10.142.20.0"
  prefix_length = "24"
  ip_type = "v4"
}

/*
docs: https://www.vultr.com/api/#tag/plans/operation/list-plans
curl "https://api.vultr.com/v2/plans?type=voc-c" \
  -X GET \
  -H "Authorization: Bearer $(joao get ~/src/nidito/config/provider/vultr.yaml key)" |
  jq -r '.plans |
    map(select((.locations | select("mex")))) |
    map([.id, .monthly_cost])[] | @tsv'
*/
resource "vultr_instance" "bernal" {
  plan = "voc-c-2c-4gb-50s-amd"
  region = "mex"
  os_id = 535 # archlinux
  label = "bernal"
  hostname = "bernal"
  enable_ipv6 = false
  backups = "disabled"
  activation_email = true
  vpc2_ids = [ vultr_vpc2.qro0.id ]
  ssh_key_ids = [ vultr_ssh_key.public.id ]
}

resource "digitalocean_record" "tepetl_net" {
  domain = "tepetl.net"
  type = "A"
  name = "qro0"
  value = vultr_instance.bernal.main_ip
}


output "bernal" {
  value = {
    ip = vultr_instance.bernal.main_ip
  }
}
