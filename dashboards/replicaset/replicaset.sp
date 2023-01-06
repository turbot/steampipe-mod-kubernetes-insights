locals {
  replicaset_common_tags = {
    service = "Kubernetes/ReplicaSet"
  }
}

category "replicaset" {
  color = local.definition_color
  href  = "/kubernetes_insights.dashboard.kubernetes_replicaset_detail?input.replicaset_uid={{.properties.'UID' | @uri}}"
  icon  = "content_copy"
  title = "Replicaset"
}
