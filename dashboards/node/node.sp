locals {
  node_common_tags = {
    service = "Kubernetes/Node"
  }
}

category "node" {
  color = local.node_color
  href  = "/kubernetes_insights.dashboard.kubernetes_node_detail?input.node_uid={{.properties.'UID' | @uri}}"
  icon  = "computer"
  title = "Node"
}
