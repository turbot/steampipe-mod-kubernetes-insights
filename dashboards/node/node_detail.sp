dashboard "node_detail" {

  title         = "Kubernetes Node Detail"
  documentation = file("./dashboards/node/docs/node_detail.md")

  tags = merge(local.node_common_tags, {
    type = "Detail"
  })

  input "node_uid" {
    title = "Select a node:"
    query = query.node_input
    width = 4
  }

  container {

    card {
      width = 3
      query = query.node_pods_count
      args = {
        uid = self.input.node_uid.value
      }
    }

    card {
      width = 3
      query = query.node_containers_count
      args = {
        uid = self.input.node_uid.value
      }
    }

  }

  with "pods_for_node" {
    query = query.pods_for_node
    args  = [self.input.node_uid.value]
  }

  with "volumes_for_node" {
    query = query.volumes_for_node
    args  = [self.input.node_uid.value]
  }

  with "endpoints_for_node" {
    query = query.endpoints_for_node
    args  = [self.input.node_uid.value]
  }

  with "clusters_for_node" {
    query = query.clusters_for_node
    args  = [self.input.node_uid.value]
  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.node
        args = {
          node_uids = [self.input.node_uid.value]
        }
      }

      node {
        base = node.cluster
        args = {
          cluster_names = with.clusters_for_node.rows[*].context_name
        }
      }

      node {
        base = node.node_volume
        args = {
          volume_names = with.volumes_for_node.rows[*].volume_name
        }
      }

      node {
        base = node.endpoint
        args = {
          endpoint_uids = with.endpoints_for_node.rows[*].uid
        }
      }

      node {
        base = node.pod
        args = {
          pod_uids = with.pods_for_node.rows[*].uid
        }
      }

      edge {
        base = edge.node_to_pod
        args = {
          node_uids = [self.input.node_uid.value]
        }
      }

      edge {
        base = edge.cluster_to_node
        args = {
          cluster_names = with.clusters_for_node.rows[*].context_name
        }
      }

      edge {
        base = edge.node_to_volume
        args = {
          node_uids = [self.input.node_uid.value]
        }
      }

      edge {
        base = edge.node_to_endpoint
        args = {
          node_uids = [self.input.node_uid.value]
        }
      }
    }
  }

  container {

    container {

      width = 6

      table {
        title = "Overview"
        width = 6
        type  = "line"
        query = query.node_overview
        args = {
          uid = self.input.node_uid.value
        }
      }

      table {
        title = "Labels"
        width = 6
        query = query.node_labels
        args = {
          uid = self.input.node_uid.value
        }
      }

    }

    container {

      width = 6

      table {
        title = "Annotations"
        query = query.node_annotations
        args = {
          uid = self.input.node_uid.value
        }
      }

      table {
        title = "Capacity"
        query = query.node_capacity
        args = {
          uid = self.input.node_uid.value
        }

      }

      table {
        title = "Allocatable"
        query = query.node_allocatable
        args = {
          uid = self.input.node_uid.value
        }

      }

      flow {
        title = "Node Hierarchy"
        query = query.node_hierarchy
        args = {
          uid = self.input.node_uid.value
        }

      }
    }

    container {

      width = 6
      table {
        title = "Pods"
        query = query.node_pod_details
        args = {
          uid = self.input.node_uid.value
        }

        column "UID" {
          display = "none"
        }

        column "Name" {
          href = "/kubernetes_insights.dashboard.pod_detail?input.pod_uid={{.'UID' | @uri}}"
        }

      }
    }

    container {

      width = 6

      table {
        title = "Addresses"
        query = query.node_addresses
        args = {
          uid = self.input.node_uid.value
        }

      }

      table {
        title = "Conditions"
        query = query.node_conditions
        args = {
          uid = self.input.node_uid.value
        }

      }
    }
  }

}

# Input queries

query "node_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'context_name', context_name
      ) as tags
    from
      kubernetes_node
    order by
      title;
  EOQ
}

# Card queries

query "node_pods_count" {
  sql = <<-EOQ
    select
      count(distinct p.name) as value,
      'Pods' as label
    from
      kubernetes_pod as p
      left join kubernetes_node as n
      on p.node_name = n.name
      and p.context_name = n.context_name
    where
      n.uid = $1;
  EOQ

  param "uid" {}
}

query "node_containers_count" {
  sql = <<-EOQ
    select
      count(c) as value,
      'Containers' as label
    from
      kubernetes_node as n,
      kubernetes_pod as p,
      jsonb_array_elements(p.containers) as c
    where
      p.node_name = n.name
      and p.context_name = n.context_name
      and n.uid = $1;
  EOQ

  param "uid" {}
}

# With queries

query "pods_for_node" {
  sql = <<-EOQ
    select
      p.uid as uid
    from
      kubernetes_pod as p,
      kubernetes_node as n
    where
      n.name = p.node_name
      and p.context_name = n.context_name
      and n.uid = $1;
  EOQ
}

query "endpoints_for_node" {
  sql = <<-EOQ
    select
      e.uid as uid
    from
      kubernetes_node as n,
      kubernetes_endpoint as e,
      jsonb_array_elements(subsets) as s,
      jsonb_array_elements(s -> 'addresses') as a
    where
      n.name = a ->> 'nodeName'
      and e.context_name = n.context_name
      and n.uid = $1;
  EOQ
}

query "volumes_for_node" {
  sql = <<-EOQ
    select
      v ->> 'name' as volume_name
    from
      kubernetes_node,
      jsonb_array_elements(volumes_attached) as v
    where
      v ->> 'name' is not null
      and uid = $1;
  EOQ
}

query "clusters_for_node" {
  sql = <<-EOQ
    select
      context_name
    from
      kubernetes_node
    where
      uid = $1;
  EOQ
}

# Other queries

query "node_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      creation_timestamp as "Create Time",
      pod_cidr as "Pod CIDR",
      context_name as "Context Name"
    from
      kubernetes_node
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "node_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_node
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

query "node_annotations" {
  sql = <<-EOQ
    with jsondata as (
   select
     annotations::json as annotation
   from
     kubernetes_node
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

query "node_capacity" {
  sql = <<-EOQ
    select
      capacity ->> 'cpu' as "CPU",
      capacity ->> 'memory' as "Memory",
      capacity ->> 'ephemeral-storage' as "Storage",
      capacity ->> 'pods' as "Pods"
    from
      kubernetes_node
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "node_allocatable" {
  sql = <<-EOQ
    select
      allocatable ->> 'cpu' as "CPU",
      allocatable ->> 'memory' as "Memory",
      allocatable ->> 'ephemeral-storage' as "Storage",
      allocatable ->> 'pods' as "Pods"
    from
      kubernetes_node
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "node_pod_details" {
  sql = <<-EOQ
    select
      p.name as "Name",
      p.uid as "UID",
      p.namespace as "Namespace",
      p.creation_timestamp as "Create Time"
    from
      kubernetes_pod as p
      left join kubernetes_node as n
      on p.node_name = n.name
      and p.context_name = n.context_name
    where
      n.uid = $1
    order by
      p.name;
  EOQ

  param "uid" {}
}

query "node_addresses" {
  sql = <<-EOQ
    select
      a ->> 'address' as "Address",
      a ->> 'type' as "Type"
    from
      kubernetes_node,
      jsonb_array_elements(addresses) as a
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "node_conditions" {
  sql = <<-EOQ
    select
      c ->> 'lastTransitionTime' as "Last Transition Time",
      c ->> 'type' as "Type",
      c ->> 'reason' as "Reason",
      c ->> 'status' as "Status",
      c ->> 'message' as "Message",
      c ->> 'lastHeartbeatTime' as "Last Heartbeat Time"
    from
      kubernetes_node,
      jsonb_array_elements(conditions) as c
    where
      uid = $1
    order by
       c ->> 'lastTransitionTime' desc;
  EOQ

  param "uid" {}
}

query "node_hierarchy" {
  sql = <<-EOQ
    -- This node
    select
      null as from_id,
      uid as id,
      name as title,
      0 as depth,
      'node' as category
    from
      kubernetes_node
    where
      uid = $1

    -- Pods associated by the nodes
    union all
    select
      n.uid as from_id,
      p.uid as id,
      p.name as title,
      1 as depth,
      'pod' as category
    from
      kubernetes_node as n
      left join kubernetes_pod as p on p.node_name = n.name
    where
      n.uid = $1

    -- containers in Pods owned by the nodes
    union all
    select
      p.uid  as from_id,
      concat(p.uid, '_', container ->> 'name') as id,
      container ->> 'name' as title,
      2 as depth,
      'container' as category
    from
      kubernetes_node as n,
      kubernetes_pod as p,
      jsonb_array_elements(p.containers) as container
    where
      n.uid = $1
      and n.name = p.node_name
  EOQ

  param "uid" {}
}
