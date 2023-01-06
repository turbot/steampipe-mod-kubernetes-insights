locals {
  daemonset_common_tags = {
    service = "Kubernetes/DaemonSet"
  }
}

category "daemonset" {
  title = "DaemonSet"
  color = local.definition_color
  href  = "/kubernetes_insights.dashboard.daemonset_detail?input.daemonset_uid={{.properties.'UID' | @uri}}"
  icon  = "copy_all"
}
