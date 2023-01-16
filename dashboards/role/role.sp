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

category "cluster_role" {
  title = "Cluster Role"
  color = local.role_color
  icon  = "engineering"
}

category "rule" {
  title = "Rule"
  color = local.role_color
  icon  = "rule_folder"
}

category "service_account" {
  title = "Service Account"
  color = local.role_color
  icon  = "settings_account_box"
}

category "user" {
  title = "User"
  color = local.role_color
  icon  = "person"
}

category "group" {
  title = "Group"
  color = local.role_color
  icon  = "group"
}
