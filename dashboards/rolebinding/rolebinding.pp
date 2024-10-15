locals {
  role_binding_common_tags = {
    service = "Kubernetes/RoleBinding"
  }
}

category "role_binding" {
  title = "Role Binding"
  color = local.role_color
  icon  = "manage_accounts"
}

category "cluster_role_binding" {
  title = "Cluster Role Binding"
  color = local.role_color
  icon  = "manage_accounts"
}
