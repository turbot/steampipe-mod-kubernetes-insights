locals {
  role_binding_common_tags = {
    service = "Kubernetes/RoleBinding"
  }
}

category "role_binding" {
  href  = "/kubernetes_insights.dashboard.kubernetes_role_binding_detail?input.role_binding_uid={{.properties.'UID' | @uri}}"
  //icon  = local.kubernetes_rolebinding_icon
  icon  = "manage_accounts"
  title = "Role Binding"
}
