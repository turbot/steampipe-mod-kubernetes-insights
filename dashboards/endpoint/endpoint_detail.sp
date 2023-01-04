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

  with "namespaces" {
    query = query.endpoint_namespaces
    args  = [self.input.endpoint_uid.value]
  }

  with "nodes" {
    query = query.endpoint_nodes
    args  = [self.input.endpoint_uid.value]
  }

  with "pods" {
    query = query.endpoint_pods
    args  = [self.input.endpoint_uid.value]
  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.endpoint
        args = {
          endpoint_uids = [self.input.endpoint_uid.value]
        }
      }

      node {
        base = node.namespace
        args = {
          namespace_uids = with.namespaces.rows[*].uid
        }
      }

      node {
        base = node.pod
        args = {
          pod_uids = with.pods.rows[*].uid
        }
      }

      node {
        base = node.node
        args = {
          node_uids = with.nodes.rows[*].uid
        }
      }

      edge {
        base = edge.namespace_to_pod
        args = {
          namespace_uids = with.namespaces.rows[*].uid
        }
      }

      edge {
        base = edge.namespace_to_endpoint
        args = {
          namespace_uids = with.namespaces.rows[*].uid
        }
      }


      edge {
        base = edge.endpoint_to_node
        args = {
          endpoint_uids = [self.input.endpoint_uid.value]
        }
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

# Input queries

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

# Card queries

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

# With queries

query "endpoint_namespaces" {
  sql = <<-EOQ
    select
      n.uid as uid
    from
      kubernetes_endpoint as e,
      kubernetes_namespace as n
    where
      n.name = e.namespace
      and n.uid is not null
      and e.uid = $1;
  EOQ
}

query "endpoint_nodes" {
  sql = <<-EOQ
    select
      n.uid as uid
    from
      kubernetes_node as n,
      kubernetes_endpoint as e,
      jsonb_array_elements(subsets) as s,
      jsonb_array_elements(s -> 'addresses') as a
    where
      n.name = a ->> 'nodeName'
      and n.uid is not null
      and e.uid = $1;
  EOQ
}

query "endpoint_pods" {
  sql = <<-EOQ
    select
      a -> 'targetRef' ->> 'uid' as uid
    from
      kubernetes_endpoint,
      jsonb_array_elements(subsets) as s,
      jsonb_array_elements(s -> 'addresses') as a
    where
      a -> 'targetRef' ->> 'uid' is not null
      and uid = $1;
  EOQ
}

# Other queries

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

