locals {
  namespace_common_tags = {
    service = "Kubernetes/Namespace"
  }
}

category "namespace" {
  href  = "/kubernetes_insights.dashboard.kubernetes_namespace_detail?input.namespace_uid={{.properties.'UID' | @uri}}"
  icon  = local.kubernetes_namespace_icon
  color = local.namespace_color
  title = "Namespace"
}
