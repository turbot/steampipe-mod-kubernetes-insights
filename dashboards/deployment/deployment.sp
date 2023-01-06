locals {
  deployment_common_tags = {
    service = "Kubernetes/Deployment"
  }
}

category "deployment" {
  href  = "/kubernetes_insights.dashboard.kubernetes_deployment_detail?input.deployment_uid={{.properties.'UID' | @uri}}"
  icon  = local.kubernetes_deployment_icon
  color = local.definition_color
  title = "Deployment"
}
