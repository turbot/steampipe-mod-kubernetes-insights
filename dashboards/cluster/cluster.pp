locals {
  cluster_common_tags = {
    service = "Kubernetes/Cluster"
  }
}

category "cluster" {
  title = "Cluster"
  color = local.cluster_color
  href  = "/kubernetes_insights.dashboard.cluster_detail?input.cluster_context={{.'id' | @uri}}"
  icon  = "tenancy"
}
