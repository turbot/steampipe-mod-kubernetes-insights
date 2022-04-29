dashboard "kubernetes_namespace_detail" {

  title         = "Kubernetes Namespace Detail"
  documentation = file("./dashboards/namespace/docs/namespace_detail.md")

  tags = merge(local.namespace_common_tags, {
    type = "Detail"
  })

  input "namespace_uid" {
    title = "Select a namespace:"
    query = query.kubernetes_namespace_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kubernetes_namespace_service_count
      args = {
        uid = self.input.namespace_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_namespace_daemonset_count
      args = {
        uid = self.input.namespace_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_namespace_deployment_count
      args = {
        uid = self.input.namespace_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_namespace_replicaset_count
      args = {
        uid = self.input.namespace_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_namespace_pod_count
      args = {
        uid = self.input.namespace_uid.value
      }
    }

  }

  container {

    container {

      width = 6

      table {
        title = "Overview"
        type  = "line"
        width = 6
        query = query.kubernetes_namespace_overview
        args = {
          uid = self.input.namespace_uid.value
        }
      }

      table {
        title = "Labels"
        width = 6
        query = query.kubernetes_namespace_labels
        args = {
          uid = self.input.namespace_uid.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Services"
        query = query.kubernetes_namespace_service_table
        args = {
          uid = self.input.namespace_uid.value
        }

        column "UID" {
          display = "none"
        }

        column "Name" {
          href = "${dashboard.kubernetes_service_detail.url_path}?input.service_uid={{.UID | @uri}}"
        }
      }

    }

    container {

      table {
        title = "DaemonSets"
        width = 6
        query = query.kubernetes_namespace_daemonset_table
        args = {
          uid = self.input.namespace_uid.value
        }

        column "UID" {
          display = "none"
        }

        column "Name" {
          href = "${dashboard.kubernetes_daemonset_detail.url_path}?input.daemonset_uid={{.UID | @uri}}"
        }
      }

      table {
        title = "Deployments"
        width = 6
        query = query.kubernetes_namespace_deployment_table
        args = {
          uid = self.input.namespace_uid.value
        }

        column "UID" {
          display = "none"
        }

        column "Name" {
          href = "${dashboard.kubernetes_deployment_detail.url_path}?input.deployment_uid={{.UID | @uri}}"
        }
      }

      table {
        title = "ReplicaSets"
        width = 6
        query = query.kubernetes_namespace_replicaset_table
        args = {
          uid = self.input.namespace_uid.value
        }

        column "UID" {
          display = "none"
        }

        column "Name" {
          href = "${dashboard.kubernetes_replicaset_detail.url_path}?input.replicaset_uid={{.UID | @uri}}"
        }
      }

      table {
        title = "Pods"
        width = 6
        query = query.kubernetes_namespace_pod_table
        args = {
          uid = self.input.namespace_uid.value
        }

        column "UID" {
          display = "none"
        }

        column "Name" {
          href = "${dashboard.kubernetes_pod_detail.url_path}?input.pod_uid={{.UID | @uri}}"
        }

      }

    }
  }
}

query "kubernetes_namespace_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'context_name', context_name
      ) as tags
    from
      kubernetes_namespace
    order by
      title;
  EOQ
}

query "kubernetes_namespace_pod_count" {
  sql = <<-EOQ
    select
      'Pods' as label,
      count(p) as value
    from
      kubernetes_pod as p,
      kubernetes_namespace as n
    where
      p.namespace = n.name and n.uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_namespace_service_count" {
  sql = <<-EOQ
    select
      'Services' as label,
      count(s) as value
    from
      kubernetes_service as s,
      kubernetes_namespace as n
    where
      s.namespace = n.name and n.uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_namespace_daemonset_count" {
  sql = <<-EOQ
    select
      'DaemonSets' as label,
      count(d) as value
    from
      kubernetes_daemonset as d,
      kubernetes_namespace as n
    where
      d.namespace = n.name and n.uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_namespace_deployment_count" {
  sql = <<-EOQ
    select
      'Deployments' as label,
      count(d) as value
    from
      kubernetes_deployment as d,
      kubernetes_namespace as n
    where
      d.namespace = n.name and n.uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_namespace_replicaset_count" {
  sql = <<-EOQ
    select
      'ReplicaSets' as label,
      count(r) as value
    from
      kubernetes_replicaset as r,
      kubernetes_namespace as n
    where
      r.namespace = n.name and n.uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_namespace_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      creation_timestamp as "Create Time",
      context_name as "Context Name"
    from
      kubernetes_namespace
    where
      uid = $1
  EOQ

  param "uid" {}
}

query "kubernetes_namespace_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_namespace
   where
     uid = $1
   )
   select
     key as "Key",
     value as "Value"
   from
     jsondata,
     json_each_text(label);
  EOQ

  param "uid" {}
}

query "kubernetes_namespace_pod_table" {
  sql = <<-EOQ
    select
      p.name as "Name",
      p.UID as "UID",
      p.restart_policy as "Restart Policy",
      p.phase as "Phase",
      p.creation_timestamp as "Create Time"
    from
      kubernetes_pod as p,
      kubernetes_namespace as n
    where
      p.namespace = n.name and n.uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_namespace_service_table" {
  sql = <<-EOQ
    select
      s.name as "Name",
      s.UID as "UID",
      s.type as "Type",
      s.cluster_ip as "Cluster IP",
      s.creation_timestamp as "Create Time"
    from
      kubernetes_service as s,
      kubernetes_namespace as n
    where
      s.namespace = n.name and n.uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_namespace_daemonset_table" {
  sql = <<-EOQ
    select
      d.name as "Name",
      d.UID as "UID",
      d.number_ready as "Node Number Ready",
      d.number_available as "Node Number Available",
      d.creation_timestamp as "Create Time"
    from
      kubernetes_daemonset as d,
      kubernetes_namespace as n
    where
      d.namespace = n.name and n.uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_namespace_deployment_table" {
  sql = <<-EOQ
    select
      d.name as "Name",
      d.UID as "UID",
      d.ready_replicas as "Ready Replicas",
      d.available_replicas as "Available Replicas",
      d.creation_timestamp as "Create Time"
    from
      kubernetes_deployment as d,
      kubernetes_namespace as n
    where
      d.namespace = n.name and n.uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_namespace_replicaset_table" {
  sql = <<-EOQ
    select
      r.name as "Name",
      r.UID as "UID",
      r.ready_replicas as "Ready Replicas",
      r.available_replicas as "Available Replicas",
      r.creation_timestamp as "Create Time"
    from
      kubernetes_replicaset as r,
      kubernetes_namespace as n
    where
      r.namespace = n.name and n.uid = $1;
  EOQ

  param "uid" {}
}


