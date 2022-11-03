category "kubernetes_deployment" {
  href = "/kubernetes_insights.dashboard.kubernetes_deployment_detail?input.deployment_uid={{.properties.'UID' | @uri}}"
  icon = local.kubernetes_deployment_icon
  fold {
    title     = "Kubernetes Deployments"
    icon      = local.kubernetes_deployment_icon
    threshold = 3
  }
}

category "kubernetes_replicaset" {
  href = "/kubernetes_insights.dashboard.kubernetes_replicaset_detail?input.replicaset_uid={{.properties.'UID' | @uri}}"
  icon = local.kubernetes_replicaset_icon
  fold {
    title     = "Kubernetes Replicasets"
    icon      = local.kubernetes_replicaset_icon
    threshold = 3
  }
}

category "kubernetes_pod" {
  href = "/kubernetes_insights.dashboard.kubernetes_pod_detail?input.pod_uid={{.properties.'UID' | @uri}}"
  icon = local.kubernetes_pod_icon
  fold {
    title     = "Kubernetes Pods"
    icon      = local.kubernetes_pod_icon
    threshold = 3
  }
}

category "kubernetes_namespace" {
  href = "/kubernetes_insights.dashboard.kubernetes_namespace_detail?input.namespace_uid={{.properties.'UID' | @uri}}"
  icon = local.kubernetes_namespace_icon
  fold {
    title     = "Kubernetes Namespaces"
    icon      = local.kubernetes_namespace_icon
    threshold = 3
  }
}

category "kubernetes_node" {
  href = "/kubernetes_insights.dashboard.kubernetes_node_detail?input.node_uid={{.properties.'UID' | @uri}}"
  icon = local.kubernetes_node_icon
  fold {
    title     = "Kubernetes Nodes"
    icon      = local.kubernetes_node_icon
    threshold = 3
  }
}

category "kubernetes_service" {
  href = "/kubernetes_insights.dashboard.kubernetes_service_detail?input.service_uid={{.properties.'UID' | @uri}}"
  icon = local.kubernetes_service_icon
  fold {
    title     = "Kubernetes Services"
    icon      = local.kubernetes_service_icon
    threshold = 3
  }
}

category "kubernetes_daemonset" {
  href = "/kubernetes_insights.dashboard.kubernetes_daemonset_detail?input.daemonset_uid={{.properties.'UID' | @uri}}"
  icon = local.kubernetes_daemonset_icon
  fold {
    title     = "Kubernetes DaemonSets"
    icon      = local.kubernetes_daemonset_icon
    threshold = 3
  }
}

category "kubernetes_statefulset" {
  href = "/kubernetes_insights.dashboard.kubernetes_statefulset_detail?input.statefulset_uid={{.properties.'UID' | @uri}}"
  icon = local.kubernetes_statefulset_icon
  fold {
    title     = "Kubernetes StatefulSets"
    icon      = local.kubernetes_statefulset_icon
    threshold = 3
  }
}

category "kubernetes_job" {
  href = "/kubernetes_insights.dashboard.kubernetes_job_detail?input.job_uid={{.properties.'UID' | @uri}}"
  icon = local.kubernetes_job_icon
  fold {
    title     = "Kubernetes Jobs"
    icon      = local.kubernetes_job_icon
    threshold = 3
  }
}

category "kubernetes_cronjob" {
  href = "/kubernetes_insights.dashboard.kubernetes_cronjob_detail?input.cronjob_uid={{.properties.'UID' | @uri}}"
  icon = local.kubernetes_cronjob_icon
  fold {
    title     = "Kubernetes CronJobs"
    icon      = local.kubernetes_cronjob_icon
    threshold = 3
  }
}

category "kubernetes_container" {
  href = "/kubernetes_insights.dashboard.kubernetes_container_detail?input.container_name={{.properties.'Name'+.properties.'POD Name' | @uri}}"
  #icon = local.aws_ec2_classic_load_balancer_icon
  fold {
    title = "Kubernetes Containers"
    #icon      = local.aws_ec2_classic_load_balancer_icon
    threshold = 3
  }
}
