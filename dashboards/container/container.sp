locals {
  container_common_tags = {
    service = "Kubernetes/Container"
  }
}

category "container" {
  title = "Container"
  color = local.container_color
  href  = "/kubernetes_insights.dashboard.container_detail?input.container_name={{.properties.'Name'+.properties.'POD Name' | @uri}}"
  icon  = "square"
}

category "init_container" {
  title = "Init Container"
  color = local.container_color
  icon  = "square"
}

category "container_volume" {
  title = "Volume"
  color = local.container_color
  icon  = "hard_drive"
}

