locals {
  daemonset_common_tags = {
    service = "Kubernetes/DaemonSet"
  }
}

category "daemonset" {
  href  = "/kubernetes_insights.dashboard.kubernetes_daemonset_detail?input.daemonset_uid={{.properties.'UID' | @uri}}"
  //icon  = local.kubernetes_daemonset_icon
  icon  = "copy_all"
  title = "DaemonSet"
}
