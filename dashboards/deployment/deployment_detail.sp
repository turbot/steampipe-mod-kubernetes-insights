dashboard "kubernetes_deployment_detail" {

  title         = "Kubernetes Deployment Detail"
  documentation = file("./dashboards/deployment/docs/deployment_detail.md")

  tags = merge(local.deployment_common_tags, {
    type = "Detail"
  })

  input "deployment_uid" {
    title = "Select a Deployment:"
    query = query.kubernetes_deployment_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kubernetes_deployment_default_namespace
      args = {
        uid = self.input.deployment_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_deployment_replica
      args = {
        uid = self.input.deployment_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_deployment_container_host_network
      args = {
        uid = self.input.deployment_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_deployment_container_host_pid
      args = {
        uid = self.input.deployment_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_deployment_container_host_ipc
      args = {
        uid = self.input.deployment_uid.value
      }
    }

  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "LR"

      nodes = [
        node.kubernetes_deployment_node,
        node.kubernetes_deployment_from_namespace_node,
        node.kubernetes_deployment_to_replicaset_node,
        node.kubernetes_deployment_to_replicaset_to_pod_node,
        node.kubernetes_deployment_to_replicaset_to_pod_to_container_node,
        node.kubernetes_deployment_to_replicaset_to_pod_to_node_node
      ]

      edges = [
        edge.kubernetes_deployment_to_replicaset_edge,
        edge.kubernetes_deployment_from_namespace_edge,
        edge.kubernetes_deployment_to_replicaset_to_pod_edge,
        edge.kubernetes_deployment_to_replicaset_to_pod_to_container_edge,
        edge.kubernetes_deployment_to_replicaset_to_pod_to_node_edge
      ]

      args = {
        uid = self.input.deployment_uid.value
      }
    }
  }

  container {

    table {
      title = "Overview"
      type  = "line"
      width = 3
      query = query.kubernetes_deployment_overview
      args = {
        uid = self.input.deployment_uid.value
      }
    }

    table {
      title = "Labels"
      width = 3
      query = query.kubernetes_deployment_labels
      args = {
        uid = self.input.deployment_uid.value
      }
    }

    table {
      title = "Annotations"
      width = 6
      query = query.kubernetes_deployment_annotations
      args = {
        uid = self.input.deployment_uid.value
      }
    }
  }

  container {

    chart {
      title = "Replicas"
      width = 4
      query = query.kubernetes_deployment_replicas_detail
      type  = "donut"
      args = {
        uid = self.input.deployment_uid.value
      }

    }

    flow {
      title = "Deployment Hierarchy"
      width = 8
      query = query.kubernetes_deployment_tree
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
      query = query.kubernetes_deployment_replicasets
      args = {
        uid = self.input.deployment_uid.value
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
      query = query.kubernetes_deployment_pods
      args = {
        uid = self.input.deployment_uid.value
      }
      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.kubernetes_pod_detail.url_path}?input.pod_uid={{.UID | @uri}}"
      }

    }


  }

  container {

    table {
      title = "Strategy"
      width = 6
      query = query.kubernetes_deployment_strategy
      args = {
        uid = self.input.deployment_uid.value
      }

    }

    table {
      title = "Conditions"
      width = 6
      query = query.kubernetes_deployment_conditions
      args = {
        uid = self.input.deployment_uid.value
      }

    }

  }

}


category "kubernetes_deployment_no_link" {
  icon = local.kubernetes_deployment_icon
}

node "kubernetes_deployment_node" {
  category = category.kubernetes_deployment_no_link

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Namespace', namespace,
        'Replicas', replicas,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_deployment_from_namespace_node" {
  category = category.kubernetes_namespace

  sql = <<-EOQ
    select
      n.uid as id,
      n.title as title,
      jsonb_build_object(
        'UID', n.uid,
        'Phase', n.phase,
        'Context Name', n.context_name
      ) as properties
    from
      kubernetes_namespace as n,
      kubernetes_deployment as d
    where
      n.name = d.namespace
      and d.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_deployment_from_namespace_edge" {
  title = "deployment"

  sql = <<-EOQ
     select
      n.uid as from_id,
      d.uid as to_id
    from
      kubernetes_namespace as n,
      kubernetes_deployment as d
    where
      n.name = d.namespace
      and d.uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_deployment_to_replicaset_node" {
  category = category.kubernetes_replicaset

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Namespace', namespace,
        'Replicas', replicas,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_replicaset,
      jsonb_array_elements(owner_references) as owner
    where
      owner ->> 'uid' = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_deployment_to_replicaset_edge" {
  title = "replicaset"

  sql = <<-EOQ
     select
      owner ->> 'uid' as from_id,
      uid as to_id
    from
      kubernetes_replicaset,
      jsonb_array_elements(owner_references) as owner
    where
      owner ->> 'uid' = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_deployment_to_replicaset_to_pod_node" {
  category = category.kubernetes_pod

  sql = <<-EOQ
    select
      pod.uid as id,
      pod.title as title,
      jsonb_build_object(
        'UID', pod.uid,
        'Namespace', pod.namespace,
        'Phase', pod.phase,
        'Context Name', pod.context_name
      ) as properties
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      rs_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = rs.uid;
  EOQ

  param "uid" {}
}

edge "kubernetes_deployment_to_replicaset_to_pod_edge" {
  title = "pod"

  sql = <<-EOQ
     select
      rs.uid as from_id,
      pod.uid as to_id
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      rs_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = rs.uid;
  EOQ

  param "uid" {}
}

node "kubernetes_deployment_to_replicaset_to_pod_to_container_node" {
  category = category.kubernetes_container

  sql = <<-EOQ
    select
      container ->> 'name' || pod.name as id,
      container ->> 'name' as title,
      jsonb_build_object(
        'Name', container ->> 'name',
        'Image', container ->> 'image',
        'POD Name', pod.name
      ) as properties
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      jsonb_array_elements(pod.containers) as container
    where
      rs_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = rs.uid;
  EOQ

  param "uid" {}
}

edge "kubernetes_deployment_to_replicaset_to_pod_to_container_edge" {
  title = "container"

  sql = <<-EOQ
     select
      pod.uid as from_id,
      container ->> 'name' || pod.name as to_id
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      jsonb_array_elements(pod.containers) as container
    where
      rs_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = rs.uid;
  EOQ

  param "uid" {}
}

node "kubernetes_deployment_to_replicaset_to_pod_to_node_node" {
  category = category.kubernetes_node

  sql = <<-EOQ
    select
      n.uid as id,
      n.name as title,
      jsonb_build_object(
        'UID', n.uid,
        'POD CIDR', n.pod_cidr,
        'Context Name', n.context_name
      ) as properties
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      kubernetes_node as n
    where
      n.name = pod.node_name
      and rs_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = rs.uid;
  EOQ

  param "uid" {}
}

edge "kubernetes_deployment_to_replicaset_to_pod_to_node_edge" {
  title = "node"

  sql = <<-EOQ
    select
      pod.uid as from_id,
      n.uid as to_id
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      kubernetes_node as n
    where
      n.name = pod.node_name
      and rs_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = rs.uid;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_input" {
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

query "kubernetes_deployment_default_namespace" {
  sql = <<-EOQ
    select
      'Namespace' as label,
      initcap(namespace) as value,
      case when namespace = 'default' then 'alert' else 'ok' end as type
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_replica" {
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

query "kubernetes_deployment_container_host_network" {
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

query "kubernetes_deployment_container_host_pid" {
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

query "kubernetes_deployment_container_host_ipc" {
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

query "kubernetes_deployment_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      creation_timestamp as "Create Time",
      context_name as "Context Name"
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_labels" {
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

query "kubernetes_deployment_annotations" {
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

query "kubernetes_deployment_conditions" {
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

query "kubernetes_deployment_strategy" {
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

query "kubernetes_deployment_replicas_detail" {
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
      case when updated_replicas <> 0 then 'updated replicas' end as label,
      case when updated_replicas <> 0 then updated_replicas end as value
    from
      kubernetes_deployment
    where
      uid = $1
    union all
    select
      case when ready_replicas <> 0 then 'ready replicas' end as label,
      case when ready_replicas <> 0 then ready_replicas end as value
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

query "kubernetes_deployment_replicasets" {
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

query "kubernetes_deployment_pods" {
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
    order by
      pod.name;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_tree" {
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
