locals {
  statefulset_common_tags = {
    service = "Kubernetes/StatefulSet"
  }
}

category "statefulset" {
  color = local.definition_color
  href  = "/kubernetes_insights.dashboard.kubernetes_statefulset_detail?input.statefulset_uid={{.properties.'UID' | @uri}}"
  icon  = "database"
  title = "StatefulSet"
}
