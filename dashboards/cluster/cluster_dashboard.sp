dashboard "kubernetes_cluster_dashboard" {

  title         = "Kubernetes Cluster Dashboard"
  documentation = file("./dashboards/cluster/docs/cluster_dashboard.md")

  tags = merge(local.cluster_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      type  = "info"
      query = query.kubernetes_cluster_count
      width = 2
      href  = dashboard.kubernetes_cluster_detail.url_path
    }

    card {
      type  = "info"
      query = query.kubernetes_cluster_namespace_count
      width = 2
      href  = dashboard.kubernetes_namespace_report.url_path
    }

    card {
      type  = "info"
      query = query.kubernetes_cluster_nodes_count
      width = 2
      href  = dashboard.kubernetes_node_report.url_path
    }

    card {
      type  = "info"
      query = query.kubernetes_cluster_services_count
      width = 2
    }

    card {
      type  = "info"
      query = query.kubernetes_cluster_pods_count
      width = 2
      href  = dashboard.kubernetes_pod_dashboard.url_path
    }

    card {
      type  = "info"
      query = query.kubernetes_cluster_containers_count
      width = 2
      href  = dashboard.kubernetes_container_dashboard.url_path
    }

    card {
      type  = "info"
      query = query.kubernetes_cluster_deployments_count
      width = 2
      href  = dashboard.kubernetes_deployment_dashboard.url_path
    }

    card {
      type  = "info"
      query = query.kubernetes_cluster_repliasets_count
      width = 2
      href  = dashboard.kubernetes_replicaset_dashboard.url_path
    }

    card {
      type  = "info"
      query = query.kubernetes_cluster_daemonsets_count
      width = 2
      href  = dashboard.kubernetes_daemonset_dashboard.url_path
    }

    card {
      type  = "info"
      query = query.kubernetes_cluster_statefulsets_count
      width = 2
      href  = dashboard.kubernetes_statefulset_dashboard.url_path
    }

    card {
      type  = "info"
      query = query.kubernetes_cluster_cronjobs_count
      width = 2
      href  = dashboard.kubernetes_cronjob_dashboard.url_path
    }

    card {
      type  = "info"
      query = query.kubernetes_cluster_jobs_count
      width = 2
      href  = dashboard.kubernetes_job_dashboard.url_path
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Namespaces by Cluster"
      query = query.kubernetes_namespace_by_context
      type  = "column"
      width = 3
    }

    chart {
      title = "Nodes by Cluster"
      query = query.kubernetes_node_by_context
      type  = "column"
      width = 3
    }

    chart {
      title = "Services by Cluster"
      query = query.kubernetes_service_by_context
      type  = "column"
      width = 3
    }

    chart {
      title = "Pods by Cluster"
      query = query.kubernetes_pod_by_context
      type  = "column"
      width = 3
    }

    chart {
      title = "Containers by Cluster"
      query = query.kubernetes_container_by_context
      type  = "column"
      width = 3
    }

    chart {
      title = "Deployments by Cluster"
      query = query.kubernetes_deployment_by_context
      type  = "column"
      width = 3
    }

    chart {
      title = "ReplicaSets by Cluster"
      query = query.kubernetes_replicaset_by_context
      type  = "column"
      width = 3
    }

    chart {
      title = "DaemonSets by Cluster"
      query = query.kubernetes_daemonset_by_context
      type  = "column"
      width = 3
    }


    chart {
      title = "StatefulSets by Cluster"
      query = query.kubernetes_statefulset_by_context
      type  = "column"
      width = 3
    }

    chart {
      title = "CronJobs by Cluster"
      query = query.kubernetes_cronjob_by_context
      type  = "column"
      width = 3
    }

    chart {
      title = "Jobs by Cluster"
      query = query.kubernetes_job_by_context
      type  = "column"
      width = 3
    }


  }

}

# Card Queries

query "kubernetes_cluster_count" {
  sql = <<-EOQ
    select
      count(distinct context_name) as "Clusters"
    from
      kubernetes_namespace;
  EOQ
}

query "kubernetes_cluster_namespace_count" {
  sql = <<-EOQ
    select
      count(*) as "Namespaces"
    from
      kubernetes_namespace;
  EOQ
}

query "kubernetes_cluster_services_count" {
  sql = <<-EOQ
    select
      count(*) as "Services"
    from
      kubernetes_service;
  EOQ
}

query "kubernetes_cluster_statefulsets_count" {
  sql = <<-EOQ
    select
      count(*) as "StatefulSets"
    from
      kubernetes_stateful_set;
  EOQ
}

query "kubernetes_cluster_pods_count" {
  sql = <<-EOQ
    select
      count(*) as "Pods"
    from
      kubernetes_pod;
  EOQ
}

query "kubernetes_cluster_nodes_count" {
  sql = <<-EOQ
    select
      count(*) as "Nodes"
    from
      kubernetes_node;
  EOQ
}

query "kubernetes_cluster_daemonsets_count" {
  sql = <<-EOQ
    select
      count(*) as "DaemonSets"
    from
      kubernetes_daemonset;
  EOQ
}

query "kubernetes_cluster_deployments_count" {
  sql = <<-EOQ
    select
      count(*) as "Deployments"
    from
      kubernetes_deployment;
  EOQ
}

query "kubernetes_cluster_cronjobs_count" {
  sql = <<-EOQ
    select
      count(*) as "CronJobs"
    from
      kubernetes_cronjob;
  EOQ
}

query "kubernetes_cluster_jobs_count" {
  sql = <<-EOQ
    select
      count(*) as "Jobs"
    from
      kubernetes_job;
  EOQ
}

query "kubernetes_cluster_repliasets_count" {
  sql = <<-EOQ
    select
      count(*) as "ReplicaSets"
    from
      kubernetes_replicaset;
  EOQ
}

query "kubernetes_cluster_containers_count" {
  sql = <<-EOQ
    select
      count(c) as "Containers"
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c;
  EOQ
}

# Analysis Queries

query "kubernetes_namespace_by_context" {
  sql = <<-EOQ
    select
      context_name,
      count(name) as "Namespaces"
    from
      kubernetes_namespace
    group by
      context_name
    order by
      context_name;
  EOQ
}

query "kubernetes_service_by_context" {
  sql = <<-EOQ
    select
      context_name,
      count(name) as "Services"
    from
      kubernetes_service
    group by
      context_name
    order by
      context_name;
  EOQ
}

query "kubernetes_statefulset_by_context" {
  sql = <<-EOQ
    select
      context_name,
      count(name) as "StatefulSets"
    from
      kubernetes_stateful_set
    group by
      context_name
    order by
      context_name;
  EOQ
}

query "kubernetes_pod_by_context" {
  sql = <<-EOQ
    select
      context_name,
      count(name) as "Pods"
    from
      kubernetes_pod
    group by
      context_name
    order by
      context_name;
  EOQ
}

query "kubernetes_node_by_context" {
  sql = <<-EOQ
    select
      context_name,
      count(name) as "Nodes"
    from
      kubernetes_node
    group by
      context_name
    order by
      context_name;
  EOQ
}

query "kubernetes_daemonset_by_context" {
  sql = <<-EOQ
    select
      context_name,
      count(name) as "DaemonSets"
    from
      kubernetes_daemonset
    group by
      context_name
    order by
      context_name;
  EOQ
}

query "kubernetes_deployment_by_context" {
  sql = <<-EOQ
    select
      context_name,
      count(name) as "Deployments"
    from
      kubernetes_deployment
    group by
      context_name
    order by
      context_name;
  EOQ
}

query "kubernetes_replicaset_by_context" {
  sql = <<-EOQ
    select
      context_name,
      count(name) as "RepicaSets"
    from
      kubernetes_replicaset
    group by
      context_name
    order by
      context_name;
  EOQ
}

query "kubernetes_cronjob_by_context" {
  sql = <<-EOQ
    select
      context_name,
      count(name) as "CronJobs"
    from
      kubernetes_cronjob
    group by
      context_name
    order by
      context_name;
  EOQ
}

query "kubernetes_job_by_context" {
  sql = <<-EOQ
    select
      context_name,
      count(name) as "Jobs"
    from
      kubernetes_job
    group by
      context_name
    order by
      context_name;
  EOQ
}

query "kubernetes_container_by_context" {
  sql = <<-EOQ
    select
      context_name,
      count(c) as "Containers"
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    group by
      context_name
    order by
      context_name;
  EOQ
}
