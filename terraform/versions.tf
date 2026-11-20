terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Talks to the Docker daemon on the machine where Terraform runs.
# Inside our Jenkins container this is the host daemon via /var/run/docker.sock.
provider "docker" {
  host = var.docker_host
}
