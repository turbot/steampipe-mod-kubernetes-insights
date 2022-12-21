dashboard "kubernetes_node_detail" {

  title         = "Kubernetes Node Detail"
  documentation = file("./dashboards/node/docs/node_detail.md")

  tags = merge(local.node_common_tags, {
    type = "Detail"
  })

  input "node_uid" {
    title = "Select a node:"
    query = query.kubernetes_node_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kubernetes_node_pods
      args = {
        uid = self.input.node_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_node_containers
      args = {
        uid = self.input.node_uid.value
      }
    }

  }

  # container {
  #   graph {
  #     title     = "Relationships"
  #     type      = "graph"
  #     direction = "TD"

  #     nodes = [
  #       node.kubernetes_node_node,
  #       node.kubernetes_node_to_pod_node,
  #       node.kubernetes_node_to_pod_to_container_node
  #     ]

  #     edges = [
  #       edge.kubernetes_node_to_pod_edge,
  #       edge.kubernetes_node_to_pod_to_container_edge
  #     ]

  #     args = {
  #       uid = self.input.node_uid.value
  #     }
  #   }
  # }

  container {

    container {

      width = 6

      table {
        title = "Overview"
        width = 6
        type  = "line"
        query = query.kubernetes_node_overview
        args = {
          uid = self.input.node_uid.value
        }
      }

      table {
        title = "Labels"
        width = 6
        query = query.kubernetes_node_labels
        args = {
          uid = self.input.node_uid.value
        }
      }

    }

    container {

      width = 6

      table {
        title = "Annotations"
        query = query.kubernetes_node_annotations
        args = {
          uid = self.input.node_uid.value
        }
      }

      table {
        title = "Capacity"
        query = query.kubernetes_node_capacity
        args = {
          uid = self.input.node_uid.value
        }

      }

      table {
        title = "Allocatable"
        query = query.kubernetes_node_allocatable
        args = {
          uid = self.input.node_uid.value
        }

      }

      flow {
        title = "Node Hierarchy"
        query = query.kubernetes_node_hierarchy
        args = {
          uid = self.input.node_uid.value
        }

      }
    }

    container {

      width = 6
      table {
        title = "Pods"
        query = query.kubernetes_node_pod_details
        args = {
          uid = self.input.node_uid.value
        }

        column "UID" {
          display = "none"
        }

        column "Name" {
          href = "/kubernetes_insights.dashboard.kubernetes_pod_detail?input.pod_uid={{.'UID' | @uri}}"
        }

      }
    }

    container {

      width = 6

      table {
        title = "Addresses"
        query = query.kubernetes_node_addresses
        args = {
          uid = self.input.node_uid.value
        }

      }

      table {
        title = "Conditions"
        query = query.kubernetes_node_conditions
        args = {
          uid = self.input.node_uid.value
        }

      }
    }
  }

}

node "kubernetes_node_to_pod_node" {
  #category = category.kubernetes_pod

  sql = <<-EOQ
    select
      p.uid as id,
      p.name as title,
      jsonb_build_object(
        'UID', p.uid,
        'Context Name', p.context_name
      ) as properties
    from
      kubernetes_pod as p,
      kubernetes_node as n
    where
      n.name = p.node_name
      and n.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_node_to_pod_edge" {
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
      and n.uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_node_to_pod_to_container_node" {
  #category = category.kubernetes_container

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
      kubernetes_node as n,
      kubernetes_pod as p,
      jsonb_array_elements(p.containers) as container
    where
      n.name = p.node_name
      and n.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_node_to_pod_to_container_edge" {
  title = "container"

  sql = <<-EOQ
     select
      p.uid as from_id,
      container ->> 'name' || p.name as to_id
    from
      kubernetes_node as n,
      kubernetes_pod as p,
      jsonb_array_elements(p.containers) as container
    where
      n.name = p.node_name
      and n.uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_node_input" {
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

query "kubernetes_node_pods" {
  sql = <<-EOQ
    select
      count(distinct p.name) as value,
      'Pods' as label
    from
      kubernetes_pod as p
      left join kubernetes_node as n on p.node_name = n.name
    where
      n.uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_node_containers" {
  sql = <<-EOQ
    select
      count(c) as value,
      'Containers' as label
    from
      kubernetes_node as n,
      kubernetes_pod as p,
      jsonb_array_elements(p.containers) as c
    where
      p.node_name = n.name and n.uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_node_overview" {
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

query "kubernetes_node_labels" {
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

query "kubernetes_node_annotations" {
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

query "kubernetes_node_capacity" {
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

query "kubernetes_node_allocatable" {
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

query "kubernetes_node_pod_details" {
  sql = <<-EOQ
    select
      p.name as "Name",
      p.uid as "UID",
      p.namespace as "Namespace",
      p.creation_timestamp as "Create Time"
    from
      kubernetes_pod as p
      left join kubernetes_node as n on p.node_name = n.name
    where
      n.uid = $1
    order by
      p.name;
  EOQ

  param "uid" {}
}

query "kubernetes_node_addresses" {
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

query "kubernetes_node_conditions" {
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

query "kubernetes_node_hierarchy" {
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
