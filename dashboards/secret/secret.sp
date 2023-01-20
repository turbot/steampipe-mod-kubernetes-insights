locals {
  secret_common_tags = {
    service = "Kubernetes/Secret"
  }
}

category "secret" {
  title = "Secret"
  color = local.role_color
  icon  = "password"
}
