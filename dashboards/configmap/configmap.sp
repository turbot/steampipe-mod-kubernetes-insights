locals {
  configmap_common_tags = {
    service = "Kubernetes/ConfigMap"
  }
}

category "configmap" {
  title = "ConfigMap"
  color = local.persistent_volume_color
  icon  = "hard_drive"
}
