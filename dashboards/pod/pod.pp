locals {
  pod_common_tags = {
    service = "Kubernetes/Pod"
  }
}

category "pod" {
  title = "Pod"
  color = local.container_color
  href  = "/kubernetes_insights.dashboard.pod_detail?input.pod_uid={{.properties.'UID' | @uri}}"
  icon  = "view_in_ar"
}
