locals {
  persistent_volume_common_tags = {
    service = "Kubernetes/PersistentVolume"
  }
}

category "persistent_volume" {
  color = local.persistent_volume_color
  href  = "/kubernetes_insights.dashboard.persistent_volume_detail?input.persistent_volume_uid={{.properties.'UID' | @uri}}"
  icon  = "hard_drive"
  title = "Persistent Volume"
}
