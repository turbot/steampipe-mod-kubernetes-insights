locals {
  configmap_common_tags = {
    service = "Kubernetes/ConfigMap"
  }
}

category "configmap" {
  title = "ConfigMap"
  color = local.configmap_color
  icon  = "text_snippet"
}
