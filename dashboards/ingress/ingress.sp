locals {
  ingress_common_tags = {
    service = "Kubernetes/Ingress"
  }
}

category "ingress" {
  title = "Ingress"
  color = local.pod_security_policy_color
  icon  = "lan"
}

category "ingress_rule" {
  title = "Rule"
  color = local.pod_security_policy_color
  icon  = "rule_folder"
}

category "ingress_rule_path" {
  title = "Path"
  color = local.pod_security_policy_color
  icon  = "arrow_forward_ios"
}

category "ingress_load_balancer" {
  title = "Load Balancer"
  color = local.pod_security_policy_color
  icon  = "mediation"
}
