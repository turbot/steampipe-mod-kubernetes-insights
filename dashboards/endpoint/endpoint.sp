locals {
  endpoint_common_tags = {
    service = "Kubernetes/Endpoint"
  }
}

category "endpoint" {
  href  = "/kubernetes_insights.dashboard.kubernetes_endpoint_detail?input.endpoint_uid={{.properties.'UID' | @uri}}"
  icon  = local.kubernetes_endpoint_icon
  title = "Endpoint"
}
