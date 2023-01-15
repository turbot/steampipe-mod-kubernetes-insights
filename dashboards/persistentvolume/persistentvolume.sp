locals {
  persistent_volume_common_tags = {
    service = "Kubernetes/PersistentVolume"
  }
}

category "persistent_volume" {
  title = "Persistent Volume"
  color = local.persistent_volume_color
  href  = "/kubernetes_insights.dashboard.persistent_volume_detail?input.persistent_volume_uid={{.properties.'UID' | @uri}}"
  icon  = "hard_drive"
}

category "persistent_volume_claim" {
  title = "Persistent Volume Claim"
  color = local.persistent_volume_color
  icon  = "hard_drive"
}
