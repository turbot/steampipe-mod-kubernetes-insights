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

      table {
        title = "Overview"
        type  = "line"
        width = 3
        query = query.kubernetes_namespace_overview
        args = {
          uid = self.input.namespace_uid.value
        }
      }

      table {
        title = "Labels"
        width = 3
        query = query.kubernetes_namespace_labels
        args = {
          uid = self.input.namespace_uid.value
        }
      }

      table {
        title = "Annotations"
        width = 6
        query = query.kubernetes_namespace_annotations
        args = {
          uid = self.input.namespace_uid.value
        }
      }

    }

    container {

      chart {
        title = "Services Type Analysis"
        width = 6
        query = query.kubernetes_service_by_type
        type  = "column"
        args = {
          uid = self.input.namespace_uid.value
        }
      }

      table {
        title = "Services"
        width = 6
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

      chart {
        title = "DaemonSets Status Analysis"
        width = 6
        query = query.kubernetes_daemonset_node_status
        type  = "column"
        args = {
          uid = self.input.namespace_uid.value
        }
      }

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

      chart {
        title = "Deployments HA Analysis"
        width = 6
        query = query.kubernetes_deployment_ha
        type  = "column"
        args = {
          uid = self.input.namespace_uid.value
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

      chart {
        title = "ReplicaSets HA Analysis"
        width = 6
        query = query.kubernetes_replicaset_ha
        type  = "column"
        args = {
          uid = self.input.namespace_uid.value
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

      chart {
        title = "Pods Phase Analysis"
        width = 6
        query = query.kubernetes_pod_by_phase
        type  = "column"
        args = {
          uid = self.input.namespace_uid.value
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
      uid = $1;
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
     json_each_text(label)
   order by
     key;
  EOQ

  param "uid" {}
}

query "kubernetes_namespace_annotations" {
  sql = <<-EOQ
    with jsondata as (
   select
     annotations::json as annotation
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
     json_each_text(annotation)
   order by
     key;
  EOQ

  param "uid" {}
}

query "kubernetes_namespace_pod_table" {
  sql = <<-EOQ
    select
      p.name as "Name",
      p.UID as "UID",
      p.phase as "Phase",
      p.creation_timestamp as "Create Time"
    from
      kubernetes_pod as p,
      kubernetes_namespace as n
    where
      p.namespace = n.name and n.uid = $1
    order by
      p.name;
  EOQ

  param "uid" {}
}

query "kubernetes_namespace_service_table" {
  sql = <<-EOQ
    select
      s.name as "Name",
      s.UID as "UID",
      s.type as "Type",
      s.creation_timestamp as "Create Time"
    from
      kubernetes_service as s,
      kubernetes_namespace as n
    where
      s.namespace = n.name and n.uid = $1
    order by
      s.name;
  EOQ

  param "uid" {}
}

query "kubernetes_namespace_daemonset_table" {
  sql = <<-EOQ
    select
      d.name as "Name",
      d.UID as "UID",
      d.desired_number_scheduled as "Desired Number Scheduled",
      d.number_ready as "Number Ready",
      d.creation_timestamp as "Create Time"
    from
      kubernetes_daemonset as d,
      kubernetes_namespace as n
    where
      d.namespace = n.name and n.uid = $1
    order by
      d.name;
  EOQ

  param "uid" {}
}

query "kubernetes_namespace_deployment_table" {
  sql = <<-EOQ
    select
      d.name as "Name",
      d.UID as "UID",
      d.replicas as "Replicas",
      d.creation_timestamp as "Create Time"
    from
      kubernetes_deployment as d,
      kubernetes_namespace as n
    where
      d.namespace = n.name and n.uid = $1
    order by
      d.name;
  EOQ

  param "uid" {}
}

query "kubernetes_namespace_replicaset_table" {
  sql = <<-EOQ
    select
      r.name as "Name",
      r.UID as "UID",
      r.replicas as "Replicas",
      r.creation_timestamp as "Create Time"
    from
      kubernetes_replicaset as r,
      kubernetes_namespace as n
    where
      r.namespace = n.name and n.uid = $1
    order by
      r.name;
  EOQ

  param "uid" {}
}

query "kubernetes_service_by_type" {
  sql = <<-EOQ
    select
      type,
      count(s.name) as "services"
    from
      kubernetes_service as s,
      kubernetes_namespace as n
    where
      s.namespace = n.name and n.uid = $1
    group by
      type
    order by
      type;
  EOQ

  param "uid" {}
}

query "kubernetes_pod_by_phase" {
  sql = <<-EOQ
    select
      p.phase,
      count(p.name) as "pods"
    from
      kubernetes_pod as p,
      kubernetes_namespace as n
    where
      p.namespace = n.name and n.uid = $1
    group by
      p.phase
    order by
      p.phase;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_ha" {
  sql = <<-EOQ
    select
      case when replicas < 3 then 'non-HA' else 'HA' end as status,
      count(d.name)
    from
      kubernetes_deployment as d,
      kubernetes_namespace as n
    where
      d.namespace = n.name and n.uid = $1
    group by
      status
    order by
      status;
  EOQ

  param "uid" {}
}

query "kubernetes_replicaset_ha" {
  sql = <<-EOQ
    select
      case when replicas < 3 then 'non-HA' else 'HA' end as status,
      count(r.name)
    from
      kubernetes_replicaset as r,
       kubernetes_namespace as n
    where
      r.namespace = n.name and n.uid = $1
    group by
      status
    order by
      status;
  EOQ

  param "uid" {}
}

query "kubernetes_daemonset_node_status" {
  sql = <<-EOQ
    select
      d.name as "Name",
      d.number_ready as "Ready",
      d.desired_number_scheduled - d.number_ready as "Not Ready"
    from
      kubernetes_daemonset as d,
      kubernetes_namespace as n
    where
      d.namespace = n.name and n.uid = $1
    order by
      d.name;
  EOQ

  param "uid" {}
}
