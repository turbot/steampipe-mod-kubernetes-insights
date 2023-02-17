dashboard "deployment_detail" {

  title         = "Kubernetes Deployment Detail"
  documentation = file("./dashboards/deployment/docs/deployment_detail.md")

  tags = merge(local.deployment_common_tags, {
    type = "Detail"
  })

  input "deployment_uid" {
    title = "Select a Deployment:"
    query = query.deployment_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.deployment_default_namespace
      args = {
        uid = self.input.deployment_uid.value
      }
      href = "/kubernetes_insights.dashboard.namespace_detail?input.namespace_uid={{.'UID' | @uri}}"
    }

    card {
      width = 2
      query = query.deployment_replica
      args = {
        uid = self.input.deployment_uid.value
      }
    }

    card {
      width = 2
      query = query.deployment_container_host_network
      args = {
        uid = self.input.deployment_uid.value
      }
    }

    card {
      width = 2
      query = query.deployment_container_host_pid
      args = {
        uid = self.input.deployment_uid.value
      }
    }

    card {
      width = 2
      query = query.deployment_container_host_ipc
      args = {
        uid = self.input.deployment_uid.value
      }
    }

  }

  with "replicasets_for_deployment" {
    query = query.replicasets_for_deployment
    args  = [self.input.deployment_uid.value]
  }

  with "services_for_deployment" {
    query = query.services_for_deployment
    args  = [self.input.deployment_uid.value]
  }

  with "pods_for_deployment" {
    query = query.pods_for_deployment
    args  = [self.input.deployment_uid.value]
  }

  with "containers_for_deployment" {
    query = query.containers_for_deployment
    args  = [self.input.deployment_uid.value]
  }

  with "nodes_for_deployment" {
    query = query.nodes_for_deployment
    args  = [self.input.deployment_uid.value]
  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.replicaset
        args = {
          replicaset_uids = with.replicasets_for_deployment.rows[*].uid
        }
      }

      node {
        base = node.service
        args = {
          service_uids = with.services_for_deployment.rows[*].uid
        }
      }

      node {
        base = node.deployment
        args = {
          deployment_uids = [self.input.deployment_uid.value]
        }
      }

      node {
        base = node.pod
        args = {
          pod_uids = with.pods_for_deployment.rows[*].uid
        }
      }

      node {
        base = node.node
        args = {
          node_uids = with.nodes_for_deployment.rows[*].uid
        }
      }

      node {
        base = node.container
        args = {
          container_names = with.containers_for_deployment.rows[*].name
        }
      }

      edge {
        base = edge.service_to_deployment
        args = {
          service_uids = with.services_for_deployment.rows[*].uid
        }
      }

      edge {
        base = edge.deployment_to_replicaset
        args = {
          deployment_uids = [self.input.deployment_uid.value]
        }
      }

      edge {
        base = edge.replicaset_to_pod
        args = {
          replicaset_uids = with.replicasets_for_deployment.rows[*].uid
        }
      }

      edge {
        base = edge.container_to_node
        args = {
          container_names = with.containers_for_deployment.rows[*].name
        }
      }

      edge {
        base = edge.pod_to_container
        args = {
          pod_uids = with.pods_for_deployment.rows[*].uid
        }
      }

    }
  }

  container {

    table {
      title = "Overview"
      type  = "line"
      width = 3
      query = query.deployment_overview
      args = {
        uid = self.input.deployment_uid.value
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
      query = query.deployment_labels
      args = {
        uid = self.input.deployment_uid.value
      }
    }

    table {
      title = "Annotations"
      width = 6
      query = query.deployment_annotations
      args = {
        uid = self.input.deployment_uid.value
      }
    }
  }

  container {

    chart {
      title = "Replicas"
      width = 4
      query = query.deployment_replicas_detail
      type  = "donut"
      args = {
        uid = self.input.deployment_uid.value
      }

    }

    flow {
      title = "Deployment Hierarchy"
      width = 8
      query = query.deployment_tree
      args = {
        uid = self.input.deployment_uid.value
      }
    }
  }

  container {
    table {
      column "UID" {
        display = "none"
      }

      title = "ReplicaSet"
      width = 6
      query = query.deployment_replicasets_detail
      args = {
        uid = self.input.deployment_uid.value
      }
      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.replicaset_detail.url_path}?input.replicaset_uid={{.UID | @uri}}"
      }
    }

    table {
      title = "Pods"
      width = 6
      query = query.deployment_pods_detail
      args = {
        uid = self.input.deployment_uid.value
      }
      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.pod_detail.url_path}?input.pod_uid={{.UID | @uri}}"
      }

    }

  }

  container {

    table {
      title = "Strategy"
      width = 6
      query = query.deployment_strategy
      args = {
        uid = self.input.deployment_uid.value
      }

    }

    table {
      title = "Conditions"
      width = 6
      query = query.deployment_conditions
      args = {
        uid = self.input.deployment_uid.value
      }

    }

  }

}

# Input queries

query "deployment_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'namespace', namespace,
        'context_name', context_name
      ) as tags
    from
      kubernetes_deployment
    order by
      title;
  EOQ
}

# Card queries

query "deployment_default_namespace" {
  sql = <<-EOQ
    select
      'Namespace' as label,
      initcap(namespace) as value,
      case when namespace = 'default' then 'alert' else 'ok' end as type,
      n.uid as "UID"
    from
      kubernetes_deployment as d,
      kubernetes_namespace as n
    where
      n.name = d.namespace
      and n.context_name = d.context_name
      and d.uid = $1;
  EOQ

  param "uid" {}
}

query "deployment_replica" {
  sql = <<-EOQ
    select
      replicas as value,
      'Replicas' as label,
      case when replicas < 3 then 'alert' else 'ok' end as type
    from
      kubernetes_deployment
    where
     uid = $1;
  EOQ

  param "uid" {}
}

query "deployment_container_host_network" {
  sql = <<-EOQ
    select
      'Host Network Access' as label,
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "deployment_container_host_pid" {
  sql = <<-EOQ
    select
      'Host PID Sharing' as label,
      case when template -> 'spec' ->> 'hostPID' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostPID' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "deployment_container_host_ipc" {
  sql = <<-EOQ
    select
      'Host IPC Sharing' as label,
      case when template -> 'spec' ->> 'hostIPC' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostIPC' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

# With queries

query "containers_for_deployment" {
  sql = <<-EOQ
    select
      container ->> 'name' || pod.name as name
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      jsonb_array_elements(pod.containers) as container
    where
      rs_owner ->> 'uid' = $1
      and rs.context_name = pod.context_name
      and pod_owner ->> 'uid' = rs.uid;
  EOQ
}

query "pods_for_deployment" {
  sql = <<-EOQ
    select
      pod.uid as uid
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      rs_owner ->> 'uid' = $1
      and rs.context_name = pod.context_name
      and pod_owner ->> 'uid' = rs.uid;
  EOQ
}

query "services_for_deployment" {
  sql = <<-EOQ
    select
      s.uid as uid
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      kubernetes_service as s
    where
      rs_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = rs.uid
      and rs.context_name = s.context_name
      and pod.selector_search = s.selector_query;
  EOQ
}

query "nodes_for_deployment" {
  sql = <<-EOQ
    select
      n.uid as uid
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      kubernetes_node as n
    where
      n.name = pod.node_name
      and rs.context_name = n.context_name
      and rs_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = rs.uid;
  EOQ
}

query "replicasets_for_deployment" {
  sql = <<-EOQ
    select
      uid
    from
      kubernetes_replicaset as r,
      jsonb_array_elements(r.owner_references) as owner
    where
      owner ->> 'uid' = $1;
  EOQ
}

# Other queries

query "deployment_overview" {
  sql = <<-EOQ
    select
      d.name as "Name",
      d.uid as "UID",
      d.creation_timestamp as "Create Time",
      n.uid as "Namespace UID",
      n.name as "Namespace",
      d.context_name as "Context Name"
    from
      kubernetes_deployment as d,
      kubernetes_namespace as n
    where
      n.name = d.namespace
      and n.context_name = d.context_name
      and d.uid = $1;
  EOQ

  param "uid" {}
}

query "deployment_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_deployment
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

query "deployment_annotations" {
  sql = <<-EOQ
    with jsondata as (
   select
     annotations::json as annotation
   from
     kubernetes_deployment
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

query "deployment_conditions" {
  sql = <<-EOQ
    select
      c ->> 'lastTransitionTime' as "Last Transition Time",
      c ->> 'lastUpdateTime' as "Last Update Time",
      c ->> 'message' as "Message",
      c ->> 'reason' as "Reason",
      c ->> 'status' as "Status",
      c ->> 'type' as "Type"
    from
      kubernetes_deployment,
      jsonb_array_elements(conditions) as c
    where
      uid = $1
    order by
      c ->> 'lastTransitionTime' desc;
  EOQ

  param "uid" {}
}

query "deployment_strategy" {
  sql = <<-EOQ
    select
      strategy ->> 'type' as "Type",
      strategy -> 'rollingUpdate' ->> 'maxSurge' as "Max Surge",
      strategy -> 'rollingUpdate' ->> 'maxUnavailable' as "Max Unavailable"
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "deployment_replicas_detail" {
  sql = <<-EOQ
    select
      case when available_replicas <> 0 then 'available replicas' end as label,
      case when available_replicas <> 0 then available_replicas end as value
    from
      kubernetes_deployment
    where
      uid = $1
    union all
    select
      case when unavailable_replicas <> 0 then 'unavailable replicas' end as label,
      case when unavailable_replicas <> 0 then unavailable_replicas end as value
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "deployment_replicasets_detail" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      min_ready_seconds as "Min Ready Seconds",
      creation_timestamp as "Create Time"
    from
      kubernetes_replicaset,
      jsonb_array_elements(owner_references) as owner
    where
      owner ->> 'uid' = $1
    order by
      name;
  EOQ

  param "uid" {}
}

query "deployment_pods_detail" {
  sql = <<-EOQ
    select
      pod.name as "Name",
      pod.uid as "UID",
      pod.restart_policy as "Restart Policy",
      pod.node_name as "Node Name"
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      rs_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = rs.uid
      and rs.context_name = pod.context_name
    order by
      pod.name;
  EOQ

  param "uid" {}
}

query "deployment_tree" {
  sql = <<-EOQ

    -- This deployment
    select
      null as from_id,
      uid as id,
      name as title,
      0 as depth,
      'deployment' as category
    from
      kubernetes_deployment
    where
      uid = $1

    -- replicasets owned by the deployment
    union all
    select
      $1 as from_id,
      uid as id,
      name as title,
      1 as depth,
      'replicaset' as category
    from
      kubernetes_replicaset,
      jsonb_array_elements(owner_references) as owner
    where
      owner ->> 'uid' = $1

    -- Pods owned by the replicasets
    union all
    select
      pod_owner ->> 'uid'  as from_id,
      pod.uid as id,
      pod.name as title,
      2 as depth,
      'pod' as category
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      rs_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = rs.uid


    -- containers in Pods owned by the replicasets
    union all
    select
      pod.uid  as from_id,
      concat(pod.uid, '_', container ->> 'name') as id,
      container ->> 'name' as title,
      3 as depth,
      'container' as category
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      jsonb_array_elements(pod.containers) as container
    where
      rs_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = rs.uid


  EOQ


  param "uid" {}

}
