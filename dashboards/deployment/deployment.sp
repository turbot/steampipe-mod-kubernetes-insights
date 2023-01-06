locals {
  deployment_common_tags = {
    service = "Kubernetes/Deployment"
  }
}

category "deployment" {
  color = local.definition_color
  href  = "/kubernetes_insights.dashboard.deployment_detail?input.deployment_uid={{.properties.'UID' | @uri}}"
  icon  = "refresh"
  title = "Deployment"
}
