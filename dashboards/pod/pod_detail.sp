dashboard "kubernetes_pod_detail" {

  title         = "Kubernetes Pod Detail"
  documentation = file("./dashboards/pod/docs/pod_detail.md")

  tags = merge(local.pod_common_tags, {
    type = "Detail"
  })

  input "pod_uid" {
    title = "Select a Pod:"
    query = query.kubernetes_pod_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kubernetes_pod_status
      args = {
        uid = self.input.pod_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_pod_container
      args = {
        uid = self.input.pod_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_pod_default_namespace
      args = {
        uid = self.input.pod_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_pod_container_host_network
      args = {
        uid = self.input.pod_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_pod_container_host_pid
      args = {
        uid = self.input.pod_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_pod_container_host_ipc
      args = {
        uid = self.input.pod_uid.value
      }
    }

  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      nodes = [
        node.kubernetes_pod_node,
        node.kubernetes_pod_to_container_node,
        node.kubernetes_pod_from_node_node,
        node.kubernetes_pod_from_namespace_node,
        node.kubernetes_pod_from_daemonset_node,
        node.kubernetes_pod_from_job_node,
        node.kubernetes_pod_from_replicaset_node,
        node.kubernetes_pod_from_statefulset_node

      ]

      edges = [
        edge.kubernetes_pod_to_container_edge,
        edge.kubernetes_pod_from_node_edge,
        edge.kubernetes_pod_from_namespace_edge,
        edge.kubernetes_pod_from_daemonset_edge,
        edge.kubernetes_pod_from_job_edge,
        edge.kubernetes_pod_from_replicaset_edge,
        edge.kubernetes_pod_from_statefulset_edge
      ]

      args = {
        uid = self.input.pod_uid.value
      }
    }
  }

  container {

    container {

      table {
        title = "Overview"
        type  = "line"
        width = 3
        query = query.kubernetes_pod_overview
        args = {
          uid = self.input.pod_uid.value
        }
      }

      table {
        title = "Labels"
        width = 3
        query = query.kubernetes_pod_labels
        args = {
          uid = self.input.pod_uid.value
        }
      }

      table {
        title = "Annotations"
        width = 6
        query = query.kubernetes_pod_annotations
        args = {
          uid = self.input.pod_uid.value
        }
      }
    }

    container {

      table {
        title = "Configuration"
        width = 6
        query = query.kubernetes_pod_configuration
        args = {
          uid = self.input.pod_uid.value
        }

        column "UID" {
          display = "none"
        }

        column "Node Name" {
          href = "${dashboard.kubernetes_node_detail.url_path}?input.node_uid={{.UID | @uri}}"
        }

      }

      table {
        title = "Containers"
        width = 6
        query = query.kubernetes_pod_container_basic_detail
        args = {
          uid = self.input.pod_uid.value
        }

        column "Container Value" {
          display = "none"
        }

        column "Name" {
          href = "${dashboard.kubernetes_container_detail.url_path}?input.container_name={{.'Container Value' | @uri}}"
        }
      }
    }
  }

  container {

    chart {
      title    = "Containers CPU Analysis"
      width    = 6
      query    = query.kubernetes_pod_container_cpu_detail
      grouping = "compare"
      type     = "column"
      args = {
        uid = self.input.pod_uid.value
      }

    }

    chart {
      title    = "Containers Memory Analysis"
      width    = 6
      query    = query.kubernetes_pod_container_memory_detail
      grouping = "compare"
      type     = "column"
      args = {
        uid = self.input.pod_uid.value
      }

    }

    table {
      title = "Init Containers"
      width = 6
      query = query.kubernetes_pod_init_containers
      args = {
        uid = self.input.pod_uid.value
      }

    }

    table {
      title = "Volumes"
      width = 6
      query = query.kubernetes_pod_volumes
      args = {
        uid = self.input.pod_uid.value
      }

    }

    table {
      title = "Conditions"
      width = 6
      query = query.kubernetes_pod_conditions
      args = {
        uid = self.input.pod_uid.value
      }

    }

  }

}

category "kubernetes_pod_no_link" {
  icon = local.kubernetes_pod_icon
}

node "kubernetes_pod_node" {
  category = category.kubernetes_pod_no_link

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Namespace', namespace,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_pod
    where
      uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_pod_from_node_node" {
  category = category.kubernetes_node

  sql = <<-EOQ
    select
      n.uid as id,
      n.name as title,
      jsonb_build_object(
        'UID', n.uid,
        'Context Name', n.context_name
      ) as properties
    from
      kubernetes_pod as p,
      kubernetes_node as n
    where
      n.name = p.node_name
      and p.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_pod_from_node_edge" {
  title = "pod"

  sql = <<-EOQ
     select
      n.uid as from_id,
      p.uid as to_id
    from
      kubernetes_pod as p,
      kubernetes_node as n
    where
      n.name = p.node_name
      and p.uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_pod_to_container_node" {
  category = category.kubernetes_container

  sql = <<-EOQ
    select
      container ->> 'name' || p.name as id,
      container ->> 'name' as title,
      jsonb_build_object(
        'Name', container ->> 'name',
        'Image', container ->> 'image',
        'POD Name', p.name
      ) as properties
    from
      kubernetes_pod as p,
      jsonb_array_elements(p.containers) as container
    where
      p.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_pod_to_container_edge" {
  title = "container"

  sql = <<-EOQ
     select
      p.uid as from_id,
      container ->> 'name' || p.name as to_id
    from
      kubernetes_pod as p,
      jsonb_array_elements(p.containers) as container
    where
      p.uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_pod_from_namespace_node" {
  category = category.kubernetes_namespace

  sql = <<-EOQ
    select
      n.uid as id,
      n.title as title,
      jsonb_build_object(
        'UID', n.uid,
        'Context Name', n.context_name
      ) as properties
    from
      kubernetes_namespace as n,
      kubernetes_pod as p
    where
      n.name = p.namespace
      and p.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_pod_from_namespace_edge" {
  title = "pod"

  sql = <<-EOQ
     select
      n.uid as from_id,
      p.uid as to_id
    from
      kubernetes_namespace as n,
      kubernetes_pod as p
    where
      n.name = p.namespace
      and p.uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_pod_from_daemonset_node" {
  category = category.kubernetes_daemonset

  sql = <<-EOQ
    select
      d.uid as id,
      d.title as title,
      jsonb_build_object(
        'UID', d.uid,
        'Namespace', d.namespace,
        'Context Name', d.context_name
      ) as properties
    from
      kubernetes_daemonset as d,
      kubernetes_pod as p,
      jsonb_array_elements(p.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = d.uid
      and p.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_pod_from_daemonset_edge" {
  title = "pod"

  sql = <<-EOQ
     select
      d.uid as from_id,
      p.uid as to_id
    from
      kubernetes_daemonset as d,
      kubernetes_pod as p,
      jsonb_array_elements(p.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = d.uid
      and p.uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_pod_from_job_node" {
  category = category.kubernetes_job

  sql = <<-EOQ
    select
      j.uid as id,
      j.title as title,
      jsonb_build_object(
        'UID', j.uid,
        'Namespace', j.namespace,
        'Context Name', j.context_name
      ) as properties
    from
      kubernetes_job as j,
      kubernetes_pod as p,
      jsonb_array_elements(p.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = j.uid
      and p.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_pod_from_job_edge" {
  title = "pod"

  sql = <<-EOQ
     select
      j.uid as from_id,
      p.uid as to_id
    from
      kubernetes_job as j,
      kubernetes_pod as p,
      jsonb_array_elements(p.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = j.uid
      and p.uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_pod_from_replicaset_node" {
  category = category.kubernetes_replicaset

  sql = <<-EOQ
    select
      r.uid as id,
      r.title as title,
      jsonb_build_object(
        'UID', r.uid,
        'Namespace', r.namespace,
        'Context Name', r.context_name
      ) as properties
    from
      kubernetes_replicaset as r,
      kubernetes_pod as p,
      jsonb_array_elements(p.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = r.uid
      and p.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_pod_from_replicaset_edge" {
  title = "pod"

  sql = <<-EOQ
     select
      r.uid as from_id,
      p.uid as to_id
    from
      kubernetes_replicaset as r,
      kubernetes_pod as p,
      jsonb_array_elements(p.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = r.uid
      and p.uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_pod_from_statefulset_node" {
  category = category.kubernetes_statefulset

  sql = <<-EOQ
    select
      s.uid as id,
      s.title as title,
      jsonb_build_object(
        'UID', s.uid,
        'Namespace', s.namespace,
        'Context Name', s.context_name
      ) as properties
    from
      kubernetes_stateful_set as s,
      kubernetes_pod as p,
      jsonb_array_elements(p.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = s.uid
      and p.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_pod_from_statefulset_edge" {
  title = "pod"

  sql = <<-EOQ
     select
      s.uid as from_id,
      p.uid as to_id
    from
      kubernetes_stateful_set as s,
      kubernetes_pod as p,
      jsonb_array_elements(p.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = s.uid
      and p.uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_pod_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'namespace', namespace,
        'context_name', context_name
      ) as tags
    from
      kubernetes_pod
    order by
      title;
  EOQ
}

query "kubernetes_pod_status" {
  sql = <<-EOQ
    select
      phase as "Phase"
    from
      kubernetes_pod
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_pod_container" {
  sql = <<-EOQ
    select
      count(c) as value,
      'Containers' as label
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_pod_default_namespace" {
  sql = <<-EOQ
    select
      'Namespace' as label,
      initcap(namespace) as value,
      case when namespace = 'default' then 'alert' else 'ok' end as type
    from
      kubernetes_pod
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_pod_container_host_network" {
  sql = <<-EOQ
    select
      'Host Network Access' as label,
      case when host_network then 'Enabled' else 'Disabled' end as value,
      case when host_network then 'alert' else 'ok' end as type
    from
      kubernetes_pod
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_pod_container_host_pid" {
  sql = <<-EOQ
    select
      'Host PID Sharing' as label,
      case when host_pid then 'Enabled' else 'Disabled' end as value,
      case when host_pid then 'alert' else 'ok' end as type
    from
      kubernetes_pod
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_pod_container_host_ipc" {
  sql = <<-EOQ
    select
      'Host IPC Sharing' as label,
      case when host_ipc then 'Enabled' else 'Disabled' end as value,
      case when host_ipc then 'alert' else 'ok' end as type
    from
      kubernetes_pod
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_pod_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      creation_timestamp as "Create Time",
      context_name as "Context Name"
    from
      kubernetes_pod
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_pod_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_pod
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

query "kubernetes_pod_annotations" {
  sql = <<-EOQ
    with jsondata as (
   select
     annotations::json as annotation
   from
     kubernetes_pod
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

query "kubernetes_pod_conditions" {
  sql = <<-EOQ
    select
      c ->> 'lastTransitionTime' as "Last Transition Time",
      c ->> 'lastProbeTime' as "Last Probe Time",
      c ->> 'status' as "Status",
      c ->> 'type' as "Type"
    from
      kubernetes_pod,
      jsonb_array_elements(conditions) as c
    where
      uid = $1
    order by
      c ->> 'lastTransitionTime' desc;
  EOQ

  param "uid" {}
}

query "kubernetes_pod_configuration" {
  sql = <<-EOQ
    select
      p.node_name as "Node Name",
      n.uid as "UID",
      priority as "Priority",
      service_account_name as "Service Account Name",
      qos_class as "QoS",
      host_ip as "Host IP",
      pod_ip as "Pod IP"
    from
      kubernetes_pod as p
      left join kubernetes_node as n on p.node_name = n.name
    where
      p.uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_pod_init_containers" {
  sql = <<-EOQ
    select
      c ->> 'name' as "Name",
      c ->> 'image' as "Image",
      c ->> 'imagePullPolicy' as "Image Pull Policy",
      c ->> 'terminationMessagePath' as "Termination Message Path",
      c ->> 'terminationMessagePolicy' as "Termination Message Policy"
    from
      kubernetes_pod,
      jsonb_array_elements(init_containers) as c
    where
      uid = $1
    order by
      c ->> 'name';
  EOQ

  param "uid" {}
}

query "kubernetes_pod_volumes" {
  sql = <<-EOQ
    select
      v ->> 'name' as "Name",
      v -> 'configMap' ->> 'name' as "ConfigMap Name",
      v -> 'configMap' ->> 'defaultMode' as "ConfigMap Default Mode"
    from
      kubernetes_pod,
      jsonb_array_elements(volumes) as v
    where
      uid = $1
    order by
      v ->> 'name';
  EOQ

  param "uid" {}
}

query "kubernetes_pod_container_basic_detail" {
  sql = <<-EOQ
    select
      c ->> 'name' as "Name",
      c ->> 'image' as "Image",
      c -> 'securityContext' -> 'seccompProfile' ->> 'type' as "Seccomp Profile Type",
      concat(c ->> 'name',name) as "Container Value"
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      uid = $1
    order by
      c ->> 'name';
  EOQ

  param "uid" {}
}

query "kubernetes_pod_container_cpu_detail" {
  sql = <<-EOQ
    select
      c ->> 'name' as "Name",
      REPLACE(c -> 'resources' -> 'limits' ->> 'cpu','m','') as "CPU Limit (m)",
      REPLACE(c -> 'resources' -> 'requests' ->> 'cpu','m','') as "CPU Request (m)"
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      uid = $1
    order by
      c ->> 'name';
  EOQ

  param "uid" {}
}

query "kubernetes_pod_container_memory_detail" {
  sql = <<-EOQ
    select
      c ->> 'name' as "Name",
      REPLACE(c -> 'resources' -> 'limits' ->> 'memory','Mi','') as "Memory Limit (Mi)",
      REPLACE(c -> 'resources' -> 'requests' ->> 'memory','Mi','') as "Memory Request (Mi)"
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      uid = $1
    order by
      c ->> 'name';
  EOQ

  param "uid" {}
}
