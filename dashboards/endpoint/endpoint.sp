locals {
  endpoint_common_tags = {
    service = "Kubernetes/Endpoint"
  }
}

category "endpoint" {
  color = local.endpoint_color
  href  = "/kubernetes_insights.dashboard.endpoint_detail?input.endpoint_uid={{.properties.'UID' | @uri}}"
  icon  = "settings_input_antenna"
  title = "Endpoint"
}
