job "git" {
  datacenters = ["nyc1"]
  region = "nyc1"

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
        // host_network = "public"
        to = 22
        static = 22
      }
    }

    task "litestream" {
      driver = "docker"
      user = 975

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
        image = "litestream/litestream:0.3.9"
        entrypoint = ["/bin/sh", "-c"]
        command = "litestream restore -if-db-not-exists /alloc/gitea.db && litestream replicate"
        volumes = [
          "secrets/litestream.yaml:/etc/litestream.yml",
        ]
      }

      template {
        data = file("litestream.yaml")
        destination = "secrets/litestream.yaml"
      }
    }

    task "git" {
      driver = "docker"
      user = 975

      config {
        image = "gitea/gitea:1.18.1-rootless"
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
