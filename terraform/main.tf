module "app" {
  source = "./modules/docker_app"

  name          = var.app_name
  image         = "${var.image_name}:${var.image_tag}"
  internal_port = var.internal_port
  external_port = var.host_port

  env_vars = [
    "PORT=${var.internal_port}",
    "APP_ENV=${var.environment}",
  ]
}
