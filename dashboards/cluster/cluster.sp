locals {
  cluster_common_tags = {
    service = "Kubernetes/Cluster"
  }
}

category "cluster" {
  title = "Cluster"
  color = local.container_color
  icon  = "tenancy"
}
