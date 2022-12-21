locals {
  daemonset_common_tags = {
    service = "Kubernetes/DaemonSet"
  }
}

category "kubernetes_daemonset" {
  href  = "/kubernetes_insights.dashboard.kubernetes_daemonset_detail?input.daemonset_uid={{.properties.'UID' | @uri}}"
  icon  = local.kubernetes_daemonset_icon
  title = "Kubernetes DaemonSet"
}
