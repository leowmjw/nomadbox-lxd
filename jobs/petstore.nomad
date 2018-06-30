job "example" {

  datacenters = ["dc1"]
  type = "service"

  update {
    max_parallel = 1
  }

  group "example" {
    count = 1
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }
    ephemeral_disk {
      size = 300
    }

    # control plane
    task "petstore" {
      env {
        DEBUG = "1"
      }
      driver = "docker"
      config {
        image = "soloio/petstore-example:latest"
        port_map {
          http = 8080
        }
      }
      resources {
        cpu = 20
        memory = 10
        network {
          mbits = 10
          port "http" {}
        }
      }
      service {
        name = "petstore"
        tags = [
          "traefik.tags=service",
          "traefik.frontend.rule=PathPrefixStrip:/petstore/",
        ]
        port = "http"
        check {
          name = "alive"
          type = "tcp"
          interval = "10s"
          timeout = "2s"
        }
      }
    }

    task "serverip" {
      driver = "raw_exec"
      config {
        # When running a binary that exists on the host, the path must be absolute.
        command = "/tmp/shared/playground-nomad"
      }

      resources {
        cpu = 20
        memory = 10
        network {
          mbits = 10
          port "http" {}
        }
      }
      service {
        name = "serverip"
        tags = [
          "traefik.tags=service",
          "traefik.frontend.rule=PathPrefixStrip:/serverip/",
        ]
        port = "http"
        check {
          name = "alive"
          type = "tcp"
          interval = "10s"
          timeout = "2s"
        }
      }

    }
  }

}
