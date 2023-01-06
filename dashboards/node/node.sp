locals {
  node_common_tags = {
    service = "Kubernetes/Node"
  }
}

category "node" {
  title = "Node"
  color = local.node_color
  href  = "/kubernetes_insights.dashboard.node_detail?input.node_uid={{.properties.'UID' | @uri}}"
  icon  = "computer"
}
