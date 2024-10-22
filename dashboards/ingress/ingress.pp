locals {
  ingress_common_tags = {
    service = "Kubernetes/Ingress"
  }
}

category "ingress" {
  title = "Ingress"
  color = local.ingress_color
  icon  = "place_item"
}

category "ingress_rule" {
  title = "Rule"
  color = local.ingress_color
  icon  = "rule_folder"
}

category "ingress_load_balancer" {
  title = "Load Balancer"
  color = local.ingress_color
  icon  = "mediation"
}
