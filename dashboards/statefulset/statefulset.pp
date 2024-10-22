locals {
  statefulset_common_tags = {
    service = "Kubernetes/StatefulSet"
  }
}

category "statefulset" {
  title = "StatefulSet"
  color = local.definition_color
  href  = "/kubernetes_insights.dashboard.statefulset_detail?input.statefulset_uid={{.properties.'UID' | @uri}}"
  icon  = "database"
}
