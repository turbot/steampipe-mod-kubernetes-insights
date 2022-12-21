locals {
  deployment_common_tags = {
    service = "Kubernetes/Deployment"
  }
}

category "kubernetes_deployment" {
  href  = "/kubernetes_insights.dashboard.kubernetes_deployment_detail?input.deployment_uid={{.properties.'UID' | @uri}}"
  icon  = local.kubernetes_deployment_icon
  title = "Kubernetes Deployment"
}
