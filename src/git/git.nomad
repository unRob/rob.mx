job "git" {
  datacenters = ["qro0"]
  region = "qro0"

  vault {
    policies = ["git-rob-mx"]

    change_mode   = "signal"
    change_signal = "SIGHUP"
  }

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

      resources {
        cpu    = 128
        memory = 64
        memory_max = 512
      }

      config {
        image = "litestream/litestream:0.3.12"
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

      resources {
        cpu    = 256
        memory = 128
        memory_max = 512
      }

      config {
        image = "litestream/litestream:0.3.12"
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

      config {
        image = "gitea/gitea:1.20.5-rootless"
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
