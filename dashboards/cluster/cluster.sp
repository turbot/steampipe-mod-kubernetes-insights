locals {
  cluster_common_tags = {
    service = "Kubernetes/Cluster"
  }
}

category "cluster" {
  href  = "/kubernetes_insights.dashboard.kubernetes_cluster_detail?input.cluster_context={{.'id' | @uri}}"
  icon  = local.kubernetes_cluster_icon
  title = "Cluster"
}
