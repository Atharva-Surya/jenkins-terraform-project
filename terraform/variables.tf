variable "docker_host" {
  description = "Docker daemon socket/URL Terraform should talk to"
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "app_name" {
  description = "Name of the container to create"
  type        = string
  default     = "cicd-demo-app"
}

variable "image_name" {
  description = "Local Docker image name built by Jenkins"
  type        = string
  default     = "cicd-demo-app"
}

variable "image_tag" {
  description = "Image tag to deploy (Jenkins passes the build number)"
  type        = string
  default     = "latest"
}

variable "internal_port" {
  description = "Port the app listens on inside the container"
  type        = number
  default     = 3000
}

variable "host_port" {
  description = "Port exposed on the Docker host"
  type        = number
  default     = 3000

  validation {
    condition     = var.host_port > 1024 && var.host_port < 65536
    error_message = "host_port must be between 1025 and 65535."
  }
}

variable "environment" {
  description = "Deployment environment label"
  type        = string
  default     = "dev"
}
