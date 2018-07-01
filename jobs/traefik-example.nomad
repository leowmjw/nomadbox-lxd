job "traefik-example" {
  region = "global"
  datacenters = ["dc1"]
  type = "service"

  update {
    max_parallel = 1    
  }

  group "web" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300
    }

    task "httpserver0" {
      driver = "docker"

      config {
        image = "python:3.6.4-alpine3.7"
        command = "python3"
        args = [
          "-m",
          "http.server",
          "8000"
        ]
        port_map {
          http = 8000
        }
        dns_servers = [
          "172.17.0.1"
        ]
        work_dir = "/var/www/html"
        volumes = [
          "/tmp/shared/demo/0:/var/www/html"
        ]
      }

      resources {
        cpu    = 100
        memory = 64
        network {
          mbits = 5
          port "http" {
            static = 8000
          }
        }
      }

      service {
        name = "httpserver0"
        tags = [
          "traefik.tags=service",
          "traefik.frontend.rule=PathPrefixStrip:/0/",
        ]
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }

    task "httpserver1" {
      driver = "docker"

      config {
        image = "python:3.6.4-alpine3.7"
        command = "python3"
        args = [
          "-m",
          "http.server",
          "8001"
        ]
        port_map {
          http = 8001
        }
        dns_servers = [
          "172.17.0.1"
        ]
        work_dir = "/var/www/html"
        volumes = [
          "/tmp/shared/demo/1:/var/www/html"
        ]
      }

      resources {
        cpu    = 100
        memory = 64
        network {
          mbits = 5
          port "http" {
            static = 8001
          }
        }
      }

      service {
        name = "httpserver1"
        tags = [
          "traefik.tags=service",
          "traefik.frontend.rule=PathPrefixStrip:/1/",
        ]
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }

}

