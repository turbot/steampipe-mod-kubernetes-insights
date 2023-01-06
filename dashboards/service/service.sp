locals {
  service_common_tags = {
    service = "Kubernetes/Service"
  }
}

category "service" {
  href  = "/kubernetes_insights.dashboard.kubernetes_service_detail?input.service_uid={{.properties.'UID' | @uri}}"
  icon  = local.kubernetes_service_icon
  color = local.service_color
  title = "Service"
}
