locals {
  role_binding_common_tags = {
    service = "Kubernetes/RoleBinding"
  }
}

category "role_binding" {
  color = local.role_color
  href  = "/kubernetes_insights.dashboard.role_binding_detail?input.role_binding_uid={{.properties.'UID' | @uri}}"
  icon  = "manage_accounts"
  title = "Role Binding"
}
