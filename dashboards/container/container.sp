locals {
  container_common_tags = {
    service = "Kubernetes/Container"
  }
}

category "container" {
  color = local.container_color
  href  = "/kubernetes_insights.dashboard.container_detail?input.container_name={{.properties.'Name'+.properties.'POD Name' | @uri}}"
  icon  = "square"
  title = "Container"
}
