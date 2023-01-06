locals {
  cluster_common_tags = {
    service = "Kubernetes/Cluster"
  }
}

category "cluster" {
  color = local.container_color
  href  = "/kubernetes_insights.dashboard.kubernetes_cluster_detail?input.cluster_context={{.'id' | @uri}}"
  icon  = "tenancy"
  title = "Cluster"
}
