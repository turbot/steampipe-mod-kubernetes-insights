locals {
  namespace_common_tags = {
    service = "Kubernetes/Namespace"
  }
}

category "namespace" {
  color = local.namespace_color
  href  = "/kubernetes_insights.dashboard.namespace_detail?input.namespace_uid={{.properties.'UID' | @uri}}"
  icon  = "format_shapes"
  title = "Namespace"
}
