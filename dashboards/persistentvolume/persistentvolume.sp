locals {
  persistent_volume_common_tags = {
    service = "Kubernetes/PersistentVolume"
  }
}

category "persistent_volume" {
  href  = "/kubernetes_insights.dashboard.kubernetes_persistent_volume_detail?input.persistent_volume_uid={{.properties.'UID' | @uri}}"
  //icon  = local.kubernetes_persistent_volume_icon
  icon  = "hard_drive"
  title = "Persistent Volume"
}
