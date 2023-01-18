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

category "rule" {
  title = "Rule"
  color = local.role_color
  icon  = "rule_folder"
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
