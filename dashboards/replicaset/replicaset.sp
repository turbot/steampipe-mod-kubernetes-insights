locals {
  replicaset_common_tags = {
    service = "Kubernetes/ReplicaSet"
  }
}

category "kubernetes_replicaset" {
  href  = "/kubernetes_insights.dashboard.kubernetes_replicaset_detail?input.replicaset_uid={{.properties.'UID' | @uri}}"
  icon  = local.kubernetes_replicaset_icon
  title = "Kubernetes Replicaset"
}
