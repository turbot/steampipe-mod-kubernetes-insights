locals {
  cluster_role_common_tags = {
    service = "Kubernetes/ClusterRole"
  }
}

category "cluster_role" {
  title = "Cluster Role"
  color = local.cluster_role_color
  href  = "/kubernetes_insights.dashboard.cluster_role_detail?input.cluster_role_uid={{.properties.'UID' | @uri}}"
  icon  = "engineering"
}

