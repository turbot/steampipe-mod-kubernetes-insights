locals {
  service_common_tags = {
    service = "Kubernetes/Service"
  }
}

category "kubernetes_service" {
  href  = "/kubernetes_insights.dashboard.kubernetes_service_detail?input.service_uid={{.properties.'UID' | @uri}}"
  icon  = local.kubernetes_service_icon
  title = "Kubernetes Service"
}
