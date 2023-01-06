locals {
  role_common_tags = {
    service = "Kubernetes/Role"
  }
}

category "role" {
  title = "Role"
  color = local.role_color
  href  = "/kubernetes_insights.dashboard.role_detail?input.role_uid={{.properties.'UID' | @uri}}"
  icon  = "engineering"
}
