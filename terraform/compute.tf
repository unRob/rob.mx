resource "digitalocean_droplet" "robmx" {
  image  = "6918990"
  name   = "rob.mx"
  region = "sfo1"
  size   = "1gb"
}
