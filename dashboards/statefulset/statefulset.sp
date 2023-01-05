locals {
  statefulset_common_tags = {
    service = "Kubernetes/StatefulSet"
  }
}

category "statefulset" {
  href  = "/kubernetes_insights.dashboard.kubernetes_statefulset_detail?input.statefulset_uid={{.properties.'UID' | @uri}}"
  //icon  = local.kubernetes_statefulset_icon
  icon  = "database"
  title = "StatefulSet"
}
