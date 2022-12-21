locals {
  container_common_tags = {
    service = "Kubernetes/Container"
  }
}

category "container" {
  href = "/kubernetes_insights.dashboard.kubernetes_container_detail?input.container_name={{.properties.'Name'+.properties.'POD Name' | @uri}}"
  #icon = local.aws_ec2_classic_load_balancer_icon
  title = "Container"
}
