dashboard "kubernetes_daemonset_detail" {

  title         = "Kubernetes DaemonSet Detail"
  documentation = file("./dashboards/daemonset/docs/daemonset_detail.md")

  tags = merge(local.daemonset_common_tags, {
    type = "Detail"
  })

  input "daemonset_uid" {
    title = "Select a DaemonSet:"
    query = query.kubernetes_daemonset_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kubernetes_daemonset_default_namespace
      args = {
        uid = self.input.daemonset_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_daemonset_container_host_network
      args = {
        uid = self.input.daemonset_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_daemonset_container_host_pid
      args = {
        uid = self.input.daemonset_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_daemonset_container_host_ipc
      args = {
        uid = self.input.daemonset_uid.value
      }
    }

  }

  # container {
  #   graph {
  #     title     = "Relationships"
  #     type      = "graph"
  #     direction = "LR"

  #     nodes = [
  #       node.kubernetes_daemonset_node,
  #       node.kubernetes_daemonset_from_namespace_node,
  #       node.kubernetes_daemonset_to_pod_node,
  #       node.kubernetes_daemonset_to_pod_to_container_node,
  #       node.kubernetes_daemonset_to_pod_to_node_node
  #     ]

  #     edges = [
  #       edge.kubernetes_daemonset_to_pod_edge,
  #       edge.kubernetes_daemonset_from_namespace_edge,
  #       edge.kubernetes_daemonset_to_pod_to_container_edge,
  #       edge.kubernetes_daemonset_to_pod_to_node_edge
  #     ]

  #     args = {
  #       uid = self.input.daemonset_uid.value
  #     }
  #   }
  # }

  container {

    table {
      title = "Overview"
      type  = "line"
      width = 3
      query = query.kubernetes_daemonset_overview
      args = {
        uid = self.input.daemonset_uid.value
      }
    }

    table {
      title = "Labels"
      width = 3
      query = query.kubernetes_daemonset_labels
      args = {
        uid = self.input.daemonset_uid.value
      }
    }

    table {
      title = "Annotations"
      width = 6
      query = query.kubernetes_daemonset_annotations
      args = {
        uid = self.input.daemonset_uid.value
      }
    }
  }

  container {

    chart {
      title = "DaemonSet Status"
      width = 4
      query = query.kubernetes_daemonset_node_detail
      type  = "donut"
      args = {
        uid = self.input.daemonset_uid.value
      }

      series "value" {
        point "not ready" {
          color = "alert"
        }
        point "ready" {
          color = "ok"
        }
      }

    }

    flow {
      title = "DaemonSet Hierarchy"
      width = 8
      query = query.kubernetes_daemonset_tree
      args = {
        uid = self.input.daemonset_uid.value
      }
    }
  }

  container {

    table {
      title = "Pods"
      width = 6
      query = query.kubernetes_daemonset_pods
      args = {
        uid = self.input.daemonset_uid.value
      }
      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.kubernetes_pod_detail.url_path}?input.pod_uid={{.UID | @uri}}"
      }

    }

    table {
      title = "Strategy"
      width = 6
      query = query.kubernetes_daemonset_strategy
      args = {
        uid = self.input.daemonset_uid.value
      }

    }

    table {
      title = "Conditions"
      width = 6
      query = query.kubernetes_daemonset_conditions
      args = {
        uid = self.input.daemonset_uid.value
      }

    }

  }

}

category "kubernetes_daemonset_no_link" {
  icon = local.kubernetes_daemonset_icon
}

node "kubernetes_daemonset_node" {
  #category = category.kubernetes_daemonset_no_link

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
      kubernetes_daemonset
    where
      uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_daemonset_from_namespace_node" {
  #category = category.kubernetes_namespace

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
      kubernetes_daemonset as d
    where
      n.name = d.namespace
      and d.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_daemonset_from_namespace_edge" {
  title = "daemonset"

  sql = <<-EOQ
     select
      n.uid as from_id,
      d.uid as to_id
    from
      kubernetes_namespace as n,
      kubernetes_daemonset as d
    where
      n.name = d.namespace
      and d.uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_daemonset_to_pod_node" {
  #category = category.kubernetes_pod

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
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_daemonset_to_pod_edge" {
  title = "pod"

  sql = <<-EOQ
     select
      pod_owner ->> 'uid' as from_id,
      uid as to_id
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_daemonset_to_pod_to_container_node" {
  #category = category.kubernetes_container

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
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      jsonb_array_elements(pod.containers) as container
    where
      pod_owner ->> 'uid' = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_daemonset_to_pod_to_container_edge" {
  title = "container"

  sql = <<-EOQ
     select
      pod.uid as from_id,
      container ->> 'name' || pod.name as to_id
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      jsonb_array_elements(pod.containers) as container
    where
      pod_owner ->> 'uid' = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_daemonset_to_pod_to_node_node" {
  #category = category.kubernetes_node

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
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      kubernetes_node as n
    where
      n.name = pod.node_name
      and pod_owner ->> 'uid' = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_daemonset_to_pod_to_node_edge" {
  title = "node"

  sql = <<-EOQ
    select
      n.uid as to_id,
      pod.uid as from_id
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      kubernetes_node as n
    where
      n.name = pod.node_name
      and pod_owner ->> 'uid' = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_daemonset_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'namespace', namespace,
        'context_name', context_name
      ) as tags
    from
      kubernetes_daemonset
    order by
      title;
  EOQ
}

query "kubernetes_daemonset_default_namespace" {
  sql = <<-EOQ
    select
      'Namespace' as label,
      initcap(namespace) as value,
      case when namespace = 'default' then 'alert' else 'ok' end as type
    from
      kubernetes_daemonset
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_daemonset_container_host_network" {
  sql = <<-EOQ
    select
      'Host Network Access' as label,
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_daemonset
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_daemonset_container_host_pid" {
  sql = <<-EOQ
    select
      'Host PID Sharing' as label,
      case when template -> 'spec' ->> 'hostPID' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostPID' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_daemonset
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_daemonset_container_host_ipc" {
  sql = <<-EOQ
    select
      'Host IPC Sharing' as label,
      case when template -> 'spec' ->> 'hostIPC' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostIPC' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_daemonset
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_daemonset_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      creation_timestamp as "Create Time",
      context_name as "Context Name"
    from
      kubernetes_daemonset
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_daemonset_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_daemonset
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

query "kubernetes_daemonset_annotations" {
  sql = <<-EOQ
    with jsondata as (
   select
     annotations::json as annotation
   from
     kubernetes_daemonset
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

query "kubernetes_daemonset_strategy" {
  sql = <<-EOQ
    select
      update_strategy ->> 'type' as "Type",
      update_strategy -> 'rollingUpdate' ->> 'maxSurge' as "Max Surge",
      update_strategy -> 'rollingUpdate' ->> 'maxUnavailable' as "Max Unavailable"
    from
      kubernetes_daemonset
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_daemonset_conditions" {
  sql = <<-EOQ
    select
      c ->> 'lastTransitionTime' as "Last Transition Time",
      c ->> 'lastUpdateTime' as "Last Update Time",
      c ->> 'message' as "Message",
      c ->> 'reason' as "Reason",
      c ->> 'status' as "Status",
      c ->> 'type' as "Type"
    from
      kubernetes_daemonset,
      jsonb_array_elements(conditions) as c
    where
      uid = $1
    order by
      c ->> 'lastTransitionTime' desc;
  EOQ

  param "uid" {}
}

query "kubernetes_daemonset_node_detail" {
  sql = <<-EOQ
    select
      case when number_ready <> 0 then 'ready' end as label,
      case when number_ready <> 0 then number_ready end as value
    from
      kubernetes_daemonset
    where
      uid = $1
    union all
    select
      case when desired_number_scheduled <> number_ready then 'not ready' end as label,
      case when desired_number_scheduled <> number_ready then desired_number_scheduled - number_ready end as value
    from
      kubernetes_daemonset
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_daemonset_pods" {
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

query "kubernetes_daemonset_tree" {
  sql = <<-EOQ

    -- This daemonset
    select
      null as from_id,
      uid as id,
      name as title,
      0 as depth,
      'job' as category
    from
      kubernetes_daemonset
    where
      uid = $1

    -- Pods owned by the daemonset
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


    -- containers in Pods owned by the daemonset
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
