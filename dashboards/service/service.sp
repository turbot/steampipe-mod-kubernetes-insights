locals {
  service_common_tags = {
    service = "Kubernetes/Service"
  }
}

category "service" {
  color = local.service_color
  href  = "/kubernetes_insights.dashboard.service_detail?input.service_uid={{.properties.'UID' | @uri}}"
  icon  = "lan"
  title = "Service"
}
