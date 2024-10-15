dashboard "statefulset_detail" {

  title         = "Kubernetes StatefulSet Detail"
  documentation = file("./dashboards/statefulset/docs/statefulset_detail.md")

  tags = merge(local.statefulset_common_tags, {
    type = "Detail"
  })

  input "statefulset_uid" {
    title = "Select a StatefulSet:"
    query = query.statefulset_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.statefulset_service_name
      args = {
        uid = self.input.statefulset_uid.value
      }
    }

    card {
      width = 2
      query = query.statefulset_replicas
      args = {
        uid = self.input.statefulset_uid.value
      }
    }

    card {
      width = 2
      query = query.statefulset_default_namespace
      args = {
        uid = self.input.statefulset_uid.value
      }
      href = "/kubernetes_insights.dashboard.namespace_detail?input.namespace_uid={{.'UID' | @uri}}"
    }

    card {
      width = 2
      query = query.statefulset_container_host_network
      args = {
        uid = self.input.statefulset_uid.value
      }
    }

    card {
      width = 2
      query = query.statefulset_container_host_pid
      args = {
        uid = self.input.statefulset_uid.value
      }
    }

    card {
      width = 2
      query = query.statefulset_container_host_ipc
      args = {
        uid = self.input.statefulset_uid.value
      }
    }

  }

  with "nodes_for_statefulset" {
    query = query.nodes_for_statefulset
    args  = [self.input.statefulset_uid.value]
  }

  with "pods_for_statefulset" {
    query = query.pods_for_statefulset
    args  = [self.input.statefulset_uid.value]
  }

  with "containers_for_statefulset" {
    query = query.statefulset_containers
    args  = [self.input.statefulset_uid.value]
  }

  with "services_for_statefulset" {
    query = query.services_for_statefulset
    args  = [self.input.statefulset_uid.value]
  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.statefulset
        args = {
          statefulset_uids = [self.input.statefulset_uid.value]
        }
      }

      node {
        base = node.service
        args = {
          service_uids = with.services_for_statefulset.rows[*].uid
        }
      }

      node {
        base = node.pod
        args = {
          pod_uids = with.pods_for_statefulset.rows[*].uid
        }
      }

      node {
        base = node.node
        args = {
          node_uids = with.nodes_for_statefulset.rows[*].uid
        }
      }

      node {
        base = node.container
        args = {
          container_names = with.containers_for_statefulset.rows[*].name
        }
      }

      edge {
        base = edge.container_to_node
        args = {
          container_names = with.containers_for_statefulset.rows[*].name
        }
      }

      edge {
        base = edge.statefulset_to_pod
        args = {
          statefulset_uids = [self.input.statefulset_uid.value]
        }
      }

      edge {
        base = edge.service_to_statefulset
        args = {
          service_uids = with.services_for_statefulset.rows[*].uid
        }
      }

      edge {
        base = edge.pod_to_container
        args = {
          pod_uids = with.pods_for_statefulset.rows[*].uid
        }
      }
    }
  }

  container {

    table {
      title = "Overview"
      type  = "line"
      width = 3
      query = query.statefulset_overview
      args = {
        uid = self.input.statefulset_uid.value
      }

      column "Namespace" {
        href = "/kubernetes_insights.dashboard.namespace_detail?input.namespace_uid={{.'Namespace UID' | @uri}}"
      }

      column "Namespace UID" {
        display = "none"
      }
    }

    table {
      title = "Labels"
      width = 3
      query = query.statefulset_labels
      args = {
        uid = self.input.statefulset_uid.value
      }
    }

    table {
      title = "Annotations"
      width = 6
      query = query.statefulset_annotations
      args = {
        uid = self.input.statefulset_uid.value
      }
    }
  }

  container {

    chart {
      title = "Replicas"
      width = 4
      query = query.statefulset_replicas_detail
      type  = "donut"
      args = {
        uid = self.input.statefulset_uid.value
      }

    }

    flow {
      title = "StatefulSet Hierarchy"
      width = 8
      query = query.statefulset_tree
      args = {
        uid = self.input.statefulset_uid.value
      }
    }

    table {
      title = "Pods"
      width = 6
      query = query.statefulset_pods_detail
      args = {
        uid = self.input.statefulset_uid.value
      }
      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.pod_detail.url_path}?input.pod_uid={{.UID | @uri}}"
      }

    }

    table {
      title = "Update Strategy"
      width = 6
      query = query.statefulset_strategy
      args = {
        uid = self.input.statefulset_uid.value
      }

    }

    table {
      title = "Conditions"
      width = 6
      query = query.statefulset_conditions
      args = {
        uid = self.input.statefulset_uid.value
      }

    }

  }

}

# Input queries

query "statefulset_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'namespace', namespace,
        'context_name', context_name
      ) as tags
    from
      kubernetes_stateful_set
    order by
      title;
  EOQ
}

# Card queries

query "statefulset_service_name" {
  sql = <<-EOQ
    select
      'Service Name' as label,
      initcap(service_name) as value
    from
      kubernetes_stateful_set
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "statefulset_replicas" {
  sql = <<-EOQ
    select
      'Replicas' as label,
      replicas as value
    from
      kubernetes_stateful_set
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "statefulset_default_namespace" {
  sql = <<-EOQ
    select
      'Namespace' as label,
      initcap(namespace) as value,
      case when namespace = 'default' then 'alert' else 'ok' end as type,
      n.uid as "UID"
    from
      kubernetes_stateful_set as s,
      kubernetes_namespace as n
    where
      n.name = s.namespace
      and n.context_name = s.context_name
      and s.uid = $1;
  EOQ

  param "uid" {}
}

query "statefulset_container_host_network" {
  sql = <<-EOQ
    select
      'Host Network Access' as label,
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_stateful_set
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "statefulset_container_host_pid" {
  sql = <<-EOQ
    select
      'Host PID Sharing' as label,
      case when template -> 'spec' ->> 'hostPID' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostPID' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_stateful_set
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "statefulset_container_host_ipc" {
  sql = <<-EOQ
    select
      'Host IPC Sharing' as label,
      case when template -> 'spec' ->> 'hostIPC' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostIPC' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_stateful_set
    where
      uid = $1;
  EOQ

  param "uid" {}
}

# With queries

query "statefulset_containers" {
  sql = <<-EOQ
    select
      container ->> 'name' || pod.name as name
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      jsonb_array_elements(pod.containers) as container
    where
      pod_owner ->> 'uid' = $1;
  EOQ
}

query "pods_for_statefulset" {
  sql = <<-EOQ
    select
      pod.uid as uid
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = $1;
  EOQ
}

query "nodes_for_statefulset" {
  sql = <<-EOQ
    select
      n.uid as uid
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      kubernetes_node as n
    where
      n.name = pod.node_name
      and pod.context_name = n.context_name
      and pod_owner ->> 'uid' = $1;
  EOQ
}

query "services_for_statefulset" {
  sql = <<-EOQ
    select
      s.uid as uid
    from
      kubernetes_stateful_set as st,
      kubernetes_service as s
    where
      st.service_name = s.name
      and s.context_name = st.context_name
      and st.uid = $1;
  EOQ
}

# Other queries

query "statefulset_overview" {
  sql = <<-EOQ
    select
      s.name as "Name",
      s.uid as "UID",
      s.creation_timestamp as "Create Time",
      n.uid as "Namespace UID",
      n.name as "Namespace",
      s.context_name as "Context Name"
    from
      kubernetes_stateful_set as s,
      kubernetes_namespace as n
    where
      n.name = s.namespace
      and n.context_name = s.context_name
      and s.uid = $1;
  EOQ

  param "uid" {}
}

query "statefulset_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_stateful_set
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

query "statefulset_annotations" {
  sql = <<-EOQ
    with jsondata as (
   select
     annotations::json as annotation
   from
     kubernetes_stateful_set
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

query "statefulset_strategy" {
  sql = <<-EOQ
    select
      update_strategy ->> 'type' as "Type",
      update_strategy -> 'rollingUpdate' ->> 'partition' as "Partition"
    from
      kubernetes_stateful_set
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "statefulset_conditions" {
  sql = <<-EOQ
    select
      c ->> 'lastTransitionTime' as "Last Transition Time",
      c ->> 'message' as "Message",
      c ->> 'reason' as "Reason",
      c ->> 'status' as "Status",
      c ->> 'type' as "Type"
    from
      kubernetes_stateful_set,
      jsonb_array_elements(conditions) as c
    where
      uid = $1
    order by
      c ->> 'lastTransitionTime' desc;
  EOQ

  param "uid" {}
}

query "statefulset_replicas_detail" {
  sql = <<-EOQ
    select
      case when current_replicas <> 0 then 'current replicas' end as label,
      case when current_replicas <> 0 then current_replicas end as value
    from
      kubernetes_stateful_set
    where
      uid = $1
    union all
    select
      case when updated_replicas <> 0 then 'updated replicas' end as label,
      case when updated_replicas <> 0 then updated_replicas end as value
    from
      kubernetes_stateful_set
    where
      uid = $1
    union all
    select
      case when ready_replicas <> 0 then 'ready replicas' end as label,
      case when ready_replicas <> 0 then ready_replicas end as value
    from
      kubernetes_stateful_set
    where
      uid = $1
    union all
    select
      case when available_replicas <> 0 then 'available replicas' end as label,
      case when available_replicas <> 0 then available_replicas end as value
    from
      kubernetes_stateful_set
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "statefulset_pods_detail" {
  sql = <<-EOQ
    select
      pod.name as "Name",
      pod.uid as "UID",
      pod.restart_policy as "Restart Policy",
      pod.node_name as "Node Name"
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = $1
    order by
      pod.name;
  EOQ

  param "uid" {}
}

query "statefulset_tree" {
  sql = <<-EOQ

    -- This statefulset
    select
      null as from_id,
      uid as id,
      name as title,
      0 as depth,
      'job' as category
    from
      kubernetes_stateful_set
    where
      uid = $1

    -- Pods owned by the statefulset
    union all
    select
      pod_owner ->> 'uid'  as from_id,
      pod.uid as id,
      pod.name as title,
      1 as depth,
      'pod' as category
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = $1


    -- containers in Pods owned by the statefulset
    union all
    select
      pod.uid  as from_id,
      concat(pod.uid, '_', container ->> 'name') as id,
      container ->> 'name' as title,
      2 as depth,
      'container' as category
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      jsonb_array_elements(pod.containers) as container
    where
      pod_owner ->> 'uid' = $1
  EOQ


  param "uid" {}

}
