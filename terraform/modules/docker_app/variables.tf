variable "name" {
  description = "Container name"
  type        = string
}

variable "image" {
  description = "Image reference including tag, e.g. cicd-demo-app:5"
  type        = string
}

variable "internal_port" {
  description = "Port inside the container"
  type        = number
}

variable "external_port" {
  description = "Port published on the host"
  type        = number
}

variable "env_vars" {
  description = "Environment variables as KEY=VALUE strings"
  type        = list(string)
  default     = []
}
