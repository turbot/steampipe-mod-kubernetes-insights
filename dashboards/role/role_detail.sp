dashboard "kubernetes_role_detail" {

  title         = "Kubernetes Role Detail"
  documentation = file("./dashboards/role/docs/role_detail.md")

  tags = merge(local.role_common_tags, {
    type = "Detail"
  })

  input "role_uid" {
    title = "Select a Role:"
    query = query.kubernetes_role_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kubernetes_role_rules_count
      args = {
        uid = self.input.role_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_role_namespace
      args = {
        uid = self.input.role_uid.value
      }
    }

  }

  with "namespaces" {
    query = query.role_namespaces
    args  = [self.input.role_uid.value]
  }

  with "role_bindings" {
    query = query.role_role_bindings
    args  = [self.input.role_uid.value]
  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.role
        args = {
          role_uids = [self.input.role_uid.value]
        }
      }

      node {
        base = node.role_binding
        args = {
          role_binding_uids = with.role_bindings.rows[*].uid
        }
      }

      node {
        base = node.namespace
        args = {
          namespace_uids = with.namespaces.rows[*].uid
        }
      }

      edge {
        base = edge.role_to_rolebinding
        args = {
          role_uids = [self.input.role_uid.value]
        }
      }

      edge {
        base = edge.namespace_to_role
        args = {
          namespace_uids = with.namespaces.rows[*].uid
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
        query = query.kubernetes_role_overview
        args = {
          uid = self.input.role_uid.value
        }
      }

      table {
        title = "Labels"
        width = 6
        query = query.kubernetes_role_labels
        args = {
          uid = self.input.role_uid.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Annotations"
        query = query.kubernetes_role_annotations
        args = {
          uid = self.input.role_uid.value
        }
      }

      table {
        title = "Rules"
        query = query.kubernetes_role_rules
        args = {
          uid = self.input.role_uid.value
        }

      }

    }

  }

}

# Input queries

query "kubernetes_role_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'context_name', context_name
      ) as tags
    from
      kubernetes_role
    order by
      title;
  EOQ
}

# Card queries

query "kubernetes_role_namespace" {
  sql = <<-EOQ
    select
      'Namespace' as label,
      initcap(namespace) as value,
      case when namespace = 'default' then 'alert' else 'ok' end as type
    from
      kubernetes_role
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_role_rules_count" {
  sql = <<-EOQ
    select
      'Rules' as label,
      count(r) as value
    from
      kubernetes_role,
      jsonb_array_elements(rules) as r
    where
      uid = $1;
  EOQ

  param "uid" {}
}

# With queries

query "role_namespaces" {
  sql = <<-EOQ
    select
      n.uid as uid
    from
      kubernetes_namespace as n,
      kubernetes_role as r
    where
      n.name = r.namespace
      and r.uid = $1;
  EOQ
}

query "role_role_bindings" {
  sql = <<-EOQ
    select
      b.uid as uid
    from
      kubernetes_role_binding as b,
      kubernetes_role as r
    where
      r.name = b.role_name
      and r.uid = $1;
  EOQ
}

# Other queries

query "kubernetes_role_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      creation_timestamp as "Create Time",
      resource_version as "Resource Version",
      context_name as "Context Name"
    from
      kubernetes_role
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_role_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_role
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

query "kubernetes_role_annotations" {
  sql = <<-EOQ
    with jsondata as (
   select
     annotations::json as annotation
   from
     kubernetes_role
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

query "kubernetes_role_rules" {
  sql = <<-EOQ
    select
      r -> 'verbs' as "Verbs",
      r -> 'apiGroups' as "API Groups",
      r -> 'resources' as "Resources",
      r -> 'resourceNames' as "Resource Names"
    from
      kubernetes_role,
      jsonb_array_elements(rules) as r
    where
      uid = $1;
  EOQ

  param "uid" {}
}
