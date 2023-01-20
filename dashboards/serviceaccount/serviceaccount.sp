locals {
  service_account_common_tags = {
    service = "Kubernetes/ServiceAccount"
  }
}

category "service_account" {
  title = "Service Account"
  color = local.container_color
  href  = "/kubernetes_insights.dashboard.service_account_detail?input.service_account_uid={{.properties.'UID' | @uri}}"
  icon  = "settings_account_box"
}

