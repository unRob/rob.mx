variable "package" {
  type = map(object({
    image   = string
    version = string
  }))
  default = {}
}

job "git" {
  datacenters = ["qro0"]
  region      = "qro0"
  namespace   = "code"


  group "git" {
    reschedule {
      delay          = "5s"
      delay_function = "fibonacci"
      max_delay      = "5m"
      unlimited      = true
    }

    restart {
      attempts = 30
      interval = "5m"
      delay = "10s"
      mode = "delay"
    }

    network {
      port "http" {
        host_network = "private"
        to = 3000
      }

      port "ssh" {
        to = 22
        static = 22
      }
    }

    task "db-restore" {
      driver = "docker"
      user = 973

      lifecycle {
        hook = "prestart"
      }

      vault {
        role = "git-rob-mx"
      }

      resources {
        cpu    = 128
        memory = 64
        memory_max = 512
      }

      config {
        image = "${var.package.litestream.image}:${var.package.litestream.version}"
        args = ["restore", "/alloc/gitea.db"]
        volumes = ["secrets/litestream.yaml:/etc/litestream.yml"]
      }

      template {
        data = file("litestream.yaml")
        destination = "secrets/litestream.yaml"
      }
    }

    task "db-replicate" {
      driver = "docker"
      user = 973

      lifecycle {
        hook = "prestart"
        sidecar = true
      }

      vault {
        role = "git-rob-mx"
      }


      resources {
        cpu    = 256
        memory = 128
        memory_max = 512
      }

      config {
        image = "${var.package.litestream.image}:${var.package.litestream.version}"
        args = ["replicate"]
        volumes = ["secrets/litestream.yaml:/etc/litestream.yml"]
      }

      template {
        data = file("litestream.yaml")
        destination = "secrets/litestream.yaml"
      }
    }

    task "git" {
      driver = "docker"
      user = 973

      vault {
        role = "git-rob-mx"
      }


      config {
        image = "${var.package.self.image}:${var.package.self.version}-rootless"
        ports = ["http", "ssh"]
        command = "gitea"
        args = ["--config", "/secrets/gitea.ini"]

        volumes = [
          "/nidito/git/repos:/repositories",
          "/nidito/git/ssh-root:/ssh-root",
          "/nidito/git/home:/var/lib/gitea",
          "/nidito/git/etc:/etc/gitea",
        ]
      }

      template {
        data = file("gitea.ini")
        destination = "secrets/gitea.ini"
      }

      template {
        data = <<-ENV
        USER_UID=975
        USER_GID=975
        APP_DATA_PATH=/var/lib/gitea
        HOME=/alloc/git/home
        USER=git
        ENV
        env = true
        destination = "local/env"
      }

      resources {
        cpu    = 256
        memory = 512
        memory_max = 768
      }

      service {
        name = "git"
        port = "http"

        tags = [
          "nidito.service",
          "nidito.dns.enabled",
          "nidito.http.enabled",
          "nidito.http.public",
          "nidito.ingress.enabled",
        ]

        meta {
          nidito-acl = "allow external"
          nidito-http-buffering = "off"
          nidito-http-wss = "on"
          nidito-http-max-body-size = "500m"
        }

        check {
          name     = "gitea"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
          address_mode = "driver"
        }
      }
    }
  }
}
