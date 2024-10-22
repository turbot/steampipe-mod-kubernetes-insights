locals {
  endpoint_common_tags = {
    service = "Kubernetes/Endpoint"
  }
}

category "endpoint" {
  title = "Endpoint"
  color = local.endpoint_color
  icon  = "settings_input_antenna"
}
