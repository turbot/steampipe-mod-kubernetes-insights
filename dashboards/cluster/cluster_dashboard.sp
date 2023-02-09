dashboard "cluster_dashboard" {

  title         = "Kubernetes Cluster Dashboard"
  documentation = file("./dashboards/cluster/docs/cluster_dashboard.md")

  tags = merge(local.cluster_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      type  = "info"
      query = query.cluster_count
      width = 2
      href  = dashboard.cluster_detail.url_path
    }

    card {
      type  = "info"
      query = query.cluster_namespace_count
      width = 2
      href  = dashboard.namespace_report.url_path
    }

    card {
      type  = "info"
      query = query.cluster_nodes_count
      width = 2
      href  = dashboard.node_report.url_path
    }

    card {
      type  = "info"
      query = query.cluster_services_count
      width = 2
    }

    card {
      type  = "info"
      query = query.cluster_pods_count
      width = 2
      href  = dashboard.pod_dashboard.url_path
    }

    card {
      type  = "info"
      query = query.cluster_containers_count
      width = 2
      href  = dashboard.container_dashboard.url_path
    }

    card {
      type  = "info"
      query = query.cluster_deployments_count
      width = 2
      href  = dashboard.deployment_dashboard.url_path
    }

    card {
      type  = "info"
      query = query.cluster_repliasets_count
      width = 2
      href  = dashboard.replicaset_dashboard.url_path
    }

    card {
      type  = "info"
      query = query.cluster_daemonsets_count
      width = 2
      href  = dashboard.daemonset_dashboard.url_path
    }

    card {
      type  = "info"
      query = query.cluster_statefulsets_count
      width = 2
      href  = dashboard.statefulset_dashboard.url_path
    }

    card {
      type  = "info"
      query = query.cluster_cronjobs_count
      width = 2
      href  = dashboard.cronjob_dashboard.url_path
    }

    card {
      type  = "info"
      query = query.cluster_jobs_count
      width = 2
      href  = dashboard.job_dashboard.url_path
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Namespaces by Cluster"
      query = query.namespace_by_context
      type  = "column"
      width = 4
    }

    chart {
      title = "Nodes by Cluster"
      query = query.node_by_context
      type  = "column"
      width = 4
    }

    chart {
      title = "Services by Cluster"
      query = query.service_by_context
      type  = "column"
      width = 4
    }

    chart {
      title = "Pods by Cluster"
      query = query.pod_by_context
      type  = "column"
      width = 4
    }

    chart {
      title = "Containers by Cluster"
      query = query.container_by_context
      type  = "column"
      width = 4
    }

    chart {
      title = "Deployments by Cluster"
      query = query.deployment_by_context
      type  = "column"
      width = 4
    }

    chart {
      title = "ReplicaSets by Cluster"
      query = query.replicaset_by_context
      type  = "column"
      width = 4
    }

    chart {
      title = "DaemonSets by Cluster"
      query = query.daemonset_by_context
      type  = "column"
      width = 4
    }


    chart {
      title = "StatefulSets by Cluster"
      query = query.statefulset_by_context
      type  = "column"
      width = 4
    }

    chart {
      title = "CronJobs by Cluster"
      query = query.cronjob_by_context
      type  = "column"
      width = 4
    }

    chart {
      title = "Jobs by Cluster"
      query = query.job_by_context
      type  = "column"
      width = 4
    }


  }

}

# Card Queries

query "cluster_count" {
  sql = <<-EOQ
    select
      count(distinct context_name) as "Clusters"
    from
      kubernetes_namespace;
  EOQ
}

query "cluster_namespace_count" {
  sql = <<-EOQ
    select
      count(*) as "Namespaces"
    from
      kubernetes_namespace;
  EOQ
}

query "cluster_services_count" {
  sql = <<-EOQ
    select
      count(*) as "Services"
    from
      kubernetes_service;
  EOQ
}

query "cluster_statefulsets_count" {
  sql = <<-EOQ
    select
      count(*) as "StatefulSets"
    from
      kubernetes_stateful_set;
  EOQ
}

query "cluster_pods_count" {
  sql = <<-EOQ
    select
      count(*) as "Pods"
    from
      kubernetes_pod;
  EOQ
}

query "cluster_nodes_count" {
  sql = <<-EOQ
    select
      count(*) as "Nodes"
    from
      kubernetes_node;
  EOQ
}

query "cluster_daemonsets_count" {
  sql = <<-EOQ
    select
      count(*) as "DaemonSets"
    from
      kubernetes_daemonset;
  EOQ
}

query "cluster_deployments_count" {
  sql = <<-EOQ
    select
      count(*) as "Deployments"
    from
      kubernetes_deployment;
  EOQ
}

query "cluster_cronjobs_count" {
  sql = <<-EOQ
    select
      count(*) as "CronJobs"
    from
      kubernetes_cronjob;
  EOQ
}

query "cluster_jobs_count" {
  sql = <<-EOQ
    select
      count(*) as "Jobs"
    from
      kubernetes_job;
  EOQ
}

query "cluster_repliasets_count" {
  sql = <<-EOQ
    select
      count(*) as "ReplicaSets"
    from
      kubernetes_replicaset;
  EOQ
}

query "cluster_containers_count" {
  sql = <<-EOQ
    select
      count(c) as "Containers"
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c;
  EOQ
}

# Analysis Queries

query "namespace_by_context" {
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

query "service_by_context" {
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

query "statefulset_by_context" {
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

query "pod_by_context" {
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

query "node_by_context" {
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

query "daemonset_by_context" {
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

query "deployment_by_context" {
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

query "replicaset_by_context" {
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

query "cronjob_by_context" {
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

query "job_by_context" {
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

query "container_by_context" {
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
