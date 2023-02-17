dashboard "replicaset_detail" {

  title         = "Kubernetes ReplicaSet Detail"
  documentation = file("./dashboards/replicaset/docs/replicaset_detail.md")

  tags = merge(local.replicaset_common_tags, {
    type = "Detail"
  })

  input "replicaset_uid" {
    title = "Select a ReplicaSet:"
    query = query.replicaset_input
    width = 4
  }

  container {

    card {
      width = 3
      query = query.replicaset_default_namespace
      args = {
        uid = self.input.replicaset_uid.value
      }
      href = "/kubernetes_insights.dashboard.namespace_detail?input.namespace_uid={{.'UID' | @uri}}"
    }

    card {
      width = 3
      query = query.replicaset_container_host_network
      args = {
        uid = self.input.replicaset_uid.value
      }
    }

    card {
      width = 3
      query = query.replicaset_container_host_pid
      args = {
        uid = self.input.replicaset_uid.value
      }
    }

    card {
      width = 3
      query = query.replicaset_container_host_ipc
      args = {
        uid = self.input.replicaset_uid.value
      }
    }

  }

  with "deployments_for_replicaset" {
    query = query.deployments_for_replicaset
    args  = [self.input.replicaset_uid.value]
  }

  with "services_for_replicaset" {
    query = query.services_for_replicaset
    args  = [self.input.replicaset_uid.value]
  }

  with "pods_for_replicaset" {
    query = query.pods_for_replicaset
    args  = [self.input.replicaset_uid.value]
  }

  with "containers_for_replicaset" {
    query = query.containers_for_replicaset
    args  = [self.input.replicaset_uid.value]
  }

  with "nodes_for_replicaset" {
    query = query.nodes_for_replicaset
    args  = [self.input.replicaset_uid.value]
  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.replicaset
        args = {
          replicaset_uids = [self.input.replicaset_uid.value]
        }
      }

      node {
        base = node.deployment
        args = {
          deployment_uids = with.deployments_for_replicaset.rows[*].uid
        }
      }

      node {
        base = node.service
        args = {
          service_uids = with.services_for_replicaset.rows[*].uid
        }
      }

      node {
        base = node.pod
        args = {
          pod_uids = with.pods_for_replicaset.rows[*].uid
        }
      }

      node {
        base = node.node
        args = {
          node_uids = with.nodes_for_replicaset.rows[*].uid
        }
      }

      node {
        base = node.container
        args = {
          container_names = with.containers_for_replicaset.rows[*].name
        }
      }

      edge {
        base = edge.service_to_deployment
        args = {
          service_uids = with.services_for_replicaset.rows[*].uid
        }
      }

      edge {
        base = edge.deployment_to_replicaset
        args = {
          deployment_uids = with.deployments_for_replicaset.rows[*].uid
        }
      }

      edge {
        base = edge.container_to_node
        args = {
          container_names = with.containers_for_replicaset.rows[*].name
        }
      }

      edge {
        base = edge.replicaset_to_pod
        args = {
          replicaset_uids = [self.input.replicaset_uid.value]
        }
      }

      edge {
        base = edge.pod_to_container
        args = {
          pod_uids = with.pods_for_replicaset.rows[*].uid
        }
      }
    }
  }

  container {

    table {
      title = "Overview"
      type  = "line"
      width = 3
      query = query.replicaset_overview
      args = {
        uid = self.input.replicaset_uid.value
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
      query = query.replicaset_labels
      args = {
        uid = self.input.replicaset_uid.value
      }
    }

    table {
      title = "Annotations"
      width = 6
      query = query.replicaset_annotations
      args = {
        uid = self.input.replicaset_uid.value
      }
    }
  }

  container {

    chart {
      title = "Replicas"
      width = 4
      query = query.replicaset_replicas_detail
      type  = "donut"
      args = {
        uid = self.input.replicaset_uid.value
      }

    }

    flow {
      title = "ReplicaSet Hierarchy"
      width = 8
      query = query.replicaset_tree
      args = {
        uid = self.input.replicaset_uid.value
      }
    }
  }

  container {

    table {
      title = "Pods"
      width = 6
      query = query.replicaset_pods_detail
      args = {
        uid = self.input.replicaset_uid.value
      }
      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.pod_detail.url_path}?input.pod_uid={{.UID | @uri}}"
      }

    }

    table {
      title = "Conditions"
      width = 6
      query = query.replicaset_conditions
      args = {
        uid = self.input.replicaset_uid.value
      }

    }

  }

}

# Input queries

query "replicaset_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'namespace', namespace,
        'context_name', context_name
      ) as tags
    from
      kubernetes_replicaset
    order by
      title;
  EOQ
}

# Card queries

query "replicaset_default_namespace" {
  sql = <<-EOQ
    select
      'Namespace' as label,
      initcap(namespace) as value,
      case when namespace = 'default' then 'alert' else 'ok' end as type,
      n.uid as "UID"
    from
      kubernetes_replicaset as r,
      kubernetes_namespace as n
    where
      n.name = r.namespace
      and n.context_name = r.context_name
      and r.uid = $1;
  EOQ

  param "uid" {}
}

query "replicaset_container_host_network" {
  sql = <<-EOQ
    select
      'Host Network Access' as label,
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_replicaset
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "replicaset_container_host_pid" {
  sql = <<-EOQ
    select
      'Host PID Sharing' as label,
      case when template -> 'spec' ->> 'hostPID' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostPID' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_replicaset
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "replicaset_container_host_ipc" {
  sql = <<-EOQ
    select
      'Host IPC Sharing' as label,
      case when template -> 'spec' ->> 'hostIPC' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostIPC' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_replicaset
    where
      uid = $1;
  EOQ

  param "uid" {}
}

# With queries

query "containers_for_replicaset" {
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

query "pods_for_replicaset" {
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

query "nodes_for_replicaset" {
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

query "deployments_for_replicaset" {
  sql = <<-EOQ
    select
      owner ->> 'uid' as uid
    from
      kubernetes_replicaset as r,
      jsonb_array_elements(r.owner_references) as owner
    where
      r.uid = $1;
  EOQ
}

query "services_for_replicaset" {
  sql = <<-EOQ
    select
      s.uid as uid
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      kubernetes_service as s
    where
      pod_owner ->> 'uid' = $1
      and s.context_name = pod.context_name
      and pod.selector_search = s.selector_query;
  EOQ
}

# Other queries

query "replicaset_overview" {
  sql = <<-EOQ
    select
      r.name as "Name",
      r.uid as "UID",
      r.creation_timestamp as "Create Time",
      n.uid as "Namespace UID",
      n.name as "Namespace",
      r.context_name as "Context Name"
    from
      kubernetes_replicaset as r,
      kubernetes_namespace as n
    where
      n.name = r.namespace
      and n.context_name = r.context_name
      and r.uid = $1;
  EOQ

  param "uid" {}
}

query "replicaset_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_replicaset
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

query "replicaset_annotations" {
  sql = <<-EOQ
    with jsondata as (
   select
     annotations::json as annotation
   from
     kubernetes_replicaset
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

query "replicaset_conditions" {
  sql = <<-EOQ
    select
      c ->> 'lastTransitionTime' as "Last Transition Time",
      c ->> 'lastUpdateTime' as "Last Update Time",
      c ->> 'message' as "Message",
      c ->> 'reason' as "Reason",
      c ->> 'status' as "Status",
      c ->> 'type' as "Type"
    from
      kubernetes_replicaset,
      jsonb_array_elements(conditions) as c
    where
      uid = $1
    order by
      c ->> 'lastTransitionTime' desc;
  EOQ

  param "uid" {}
}

query "replicaset_replicas_detail" {
  sql = <<-EOQ
    select
      case when status_replicas <> 0 then 'status replicas' end as label,
      case when status_replicas <> 0 then status_replicas end as value
    from
      kubernetes_replicaset
    where
      uid = $1
    union all
    select
      case when fully_labeled_replicas <> 0 then 'fully labeled replicas' end as label,
      case when fully_labeled_replicas <> 0 then fully_labeled_replicas end as value
    from
      kubernetes_replicaset
    where
      uid = $1
    union all
    select
      case when ready_replicas <> 0 then 'ready replicas' end as label,
      case when ready_replicas <> 0 then ready_replicas end as value
    from
      kubernetes_replicaset
    where
      uid = $1
    union all
    select
      case when available_replicas <> 0 then 'available replicas' end as label,
      case when available_replicas <> 0 then available_replicas end as value
    from
      kubernetes_replicaset
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "replicaset_pods_detail" {
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

query "replicaset_tree" {
  sql = <<-EOQ

    -- This replicaset
    select
      null as from_id,
      uid as id,
      name as title,
      0 as depth,
      'job' as category
    from
      kubernetes_replicaset
    where
      uid = $1

    -- Pods owned by the replicaset
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


    -- containers in Pods owned by the replicaset
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
