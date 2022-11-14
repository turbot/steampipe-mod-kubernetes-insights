dashboard "kubernetes_endpoint_detail" {

  title         = "Kubernetes Endpoint Detail"
  documentation = file("./dashboards/endpoint/docs/endpoint_detail.md")

  tags = merge(local.endpoint_common_tags, {
    type = "Detail"
  })

  input "endpoint_uid" {
    title = "Select an Endpoint:"
    query = query.kubernetes_endpoint_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kubernetes_endpoint_subset_count
      args = {
        uid = self.input.endpoint_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_endpoint_namespace
      args = {
        uid = self.input.endpoint_uid.value
      }
    }

  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "LR"

      nodes = [
        node.kubernetes_endpoint_node,
        node.kubernetes_endpoint_from_namespace_node,
        node.kubernetes_endpoint_from_node_node,
        node.kubernetes_endpoint_from_pod_node,
      ]

      edges = [
        edge.kubernetes_endpoint_from_namespace_edge,
        edge.kubernetes_endpoint_from_node_edge,
        edge.kubernetes_endpoint_from_pod_edge
      ]

      args = {
        uid = self.input.endpoint_uid.value
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
        query = query.kubernetes_endpoint_overview
        args = {
          uid = self.input.endpoint_uid.value
        }
      }

      table {
        title = "Labels"
        width = 6
        query = query.kubernetes_endpoint_labels
        args = {
          uid = self.input.endpoint_uid.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Annotations"
        query = query.kubernetes_endpoint_annotations
        args = {
          uid = self.input.endpoint_uid.value
        }
      }

      table {
        title = "Ports"
        query = query.kubernetes_endpoint_ports
        args = {
          uid = self.input.endpoint_uid.value
        }

      }

      table {
        title = "Addresses"
        query = query.kubernetes_endpoint_addresses
        args = {
          uid = self.input.endpoint_uid.value
        }

      }

    }

  }

}

category "kubernetes_endpoint_no_link" {
  icon = local.kubernetes_endpoint_icon
}

node "kubernetes_endpoint_node" {
  category = category.kubernetes_endpoint_no_link

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_endpoint
    where
      uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_endpoint_from_namespace_node" {
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
      kubernetes_endpoint as e,
      kubernetes_namespace as n
    where
      n.name = e.namespace
      and e.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_endpoint_from_namespace_edge" {
  title = "endpoint"

  sql = <<-EOQ
     select
      n.uid as from_id,
      e.uid as to_id
    from
      kubernetes_endpoint as e,
      kubernetes_namespace as n
    where
      n.name = e.namespace
      and e.uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_endpoint_from_node_node" {
  category = category.kubernetes_node

  sql = <<-EOQ
    select
      n.uid as id,
      n.title as title,
      jsonb_build_object(
        'UID', n.uid,
        'Context Name', n.context_name
      ) as properties
    from
      kubernetes_node as n,
      kubernetes_endpoint as e,
      jsonb_array_elements(subsets) as s,
      jsonb_array_elements(s -> 'addresses') as a
    where
      n.name = a ->> 'nodeName'
      and e.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_endpoint_from_node_edge" {
  title = "endpoint"

  sql = <<-EOQ
     select
      n.uid as from_id,
      e.uid as to_id
    from
      kubernetes_node as n,
      kubernetes_endpoint as e,
      jsonb_array_elements(subsets) as s,
      jsonb_array_elements(s -> 'addresses') as a
    where
      n.name = a ->> 'nodeName'
      and e.uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_endpoint_from_pod_node" {
  category = category.kubernetes_pod

  sql = <<-EOQ
    select
      p.uid as id,
      p.title as title,
      jsonb_build_object(
        'UID', p.uid,
        'Context Name', p.context_name
      ) as properties
    from
      kubernetes_pod as p,
      kubernetes_endpoint as e,
      jsonb_array_elements(subsets) as s,
      jsonb_array_elements(s -> 'addresses') as a
    where
      p.uid = a -> 'targetRef' ->> 'uid'
      and e.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_endpoint_from_pod_edge" {
  title = "endpoint"

  sql = <<-EOQ
     select
      p.uid as from_id,
      e.uid as to_id
    from
      kubernetes_pod as p,
      kubernetes_endpoint as e,
      jsonb_array_elements(subsets) as s,
      jsonb_array_elements(s -> 'addresses') as a
    where
      p.uid = a -> 'targetRef' ->> 'uid'
      and e.uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_endpoint_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'context_name', context_name
      ) as tags
    from
      kubernetes_endpoint
    order by
      title;
  EOQ
}

query "kubernetes_endpoint_namespace" {
  sql = <<-EOQ
    select
      'Namespace' as label,
      initcap(namespace) as value,
      case when namespace = 'default' then 'alert' else 'ok' end as type
    from
      kubernetes_endpoint
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_endpoint_subset_count" {
  sql = <<-EOQ
    select
      'Subsets' as label,
      count(s) as value
    from
      kubernetes_endpoint,
      jsonb_array_elements(subsets) as s
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_endpoint_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      creation_timestamp as "Create Time",
      resource_version as "Resource Version",
      context_name as "Context Name"
    from
      kubernetes_endpoint
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_endpoint_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_endpoint
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

query "kubernetes_endpoint_annotations" {
  sql = <<-EOQ
    with jsondata as (
   select
     annotations::json as annotation
   from
     kubernetes_endpoint
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

query "kubernetes_endpoint_ports" {
  sql = <<-EOQ
    select
      p ->> 'name' as "Name",
      p ->> 'port' as "Port",
      p ->> 'protocol' as "Protocol"
    from
      kubernetes_endpoint,
      jsonb_array_elements(subsets) as s,
      jsonb_array_elements(s -> 'ports') as p
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_endpoint_addresses" {
  sql = <<-EOQ
    select
      a ->> 'ip' as "IP",
      a ->> 'nodeName' as "Node Name",
      a ->  'targetRef' ->> 'uid' as "Target Ref UID",
      a ->  'targetRef' ->> 'kind' as "Target Ref Kind",
      a ->  'targetRef' ->> 'name' as "Target Ref Name",
      a ->  'targetRef' ->> 'resourceVersion' as "Target Ref Resource Version"
    from
      kubernetes_endpoint,
      jsonb_array_elements(subsets) as s,
      jsonb_array_elements(s -> 'addresses') as a
    where
      uid = $1;
  EOQ

  param "uid" {}
}

