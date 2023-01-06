locals {
  node_common_tags = {
    service = "Kubernetes/Node"
  }
}

category "node" {
  href  = "/kubernetes_insights.dashboard.kubernetes_node_detail?input.node_uid={{.properties.'UID' | @uri}}"
  icon  = local.kubernetes_node_icon
  color = local.node_color
  title = "Node"
}
