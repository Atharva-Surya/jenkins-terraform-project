terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_container" "app" {
  name    = var.name
  image   = var.image
  restart = "unless-stopped"
  env     = var.env_vars

  ports {
    internal = var.internal_port
    external = var.external_port
  }

  labels {
    label = "managed-by"
    value = "terraform"
  }
}
