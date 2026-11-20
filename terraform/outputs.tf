output "container_name" {
  description = "Name of the deployed container"
  value       = module.app.container_name
}

output "container_id" {
  description = "ID of the deployed container"
  value       = module.app.container_id
}

output "app_url" {
  description = "URL to open the app on the Docker host"
  value       = "http://localhost:${var.host_port}"
}
