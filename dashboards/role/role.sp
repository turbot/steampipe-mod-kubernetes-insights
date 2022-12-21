locals {
  role_common_tags = {
    service = "Kubernetes/Role"
  }
}

category "role" {
  href  = "/kubernetes_insights.dashboard.kubernetes_role_detail?input.role_uid={{.properties.'UID' | @uri}}"
  icon  = local.kubernetes_role_icon
  title = "Role"
}
