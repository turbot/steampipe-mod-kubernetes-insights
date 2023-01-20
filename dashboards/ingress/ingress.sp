locals {
  ingress_common_tags = {
    service = "Kubernetes/Ingress"
  }
}

category "ingress" {
  title = "Ingress"
  color = local.ingress_color
  icon  = "lan"
}

category "ingress_rule" {
  title = "Rule"
  color = local.ingress_color
  icon  = "rule_folder"
}

category "ingress_rule_path" {
  title = "Path"
  color = local.ingress_color
  icon  = "arrow_forward_ios"
}

category "ingress_load_balancer" {
  title = "Load Balancer"
  color = local.ingress_color
  icon  = "mediation"
}
