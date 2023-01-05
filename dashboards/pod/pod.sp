locals {
  pod_common_tags = {
    service = "Kubernetes/Pod"
  }
}

category "pod" {
  href  = "/kubernetes_insights.dashboard.kubernetes_pod_detail?input.pod_uid={{.properties.'UID' | @uri}}"
  //icon  = local.kubernetes_pod_icon
  icon  = "view_in_ar"
  title = "Pod"
}
