dashboard "role_detail" {

  title         = "Kubernetes Role Detail"
  documentation = file("./dashboards/role/docs/role_detail.md")

  tags = merge(local.role_common_tags, {
    type = "Detail"
  })

  input "role_uid" {
    title = "Select a Role:"
    query = query.role_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.role_rules_count
      args = {
        uid = self.input.role_uid.value
      }
    }

    card {
      width = 2
      query = query.role_namespace
      args = {
        uid = self.input.role_uid.value
      }
    }

  }

  with "service_accounts" {
    query = query.role_service_accounts
    args  = [self.input.role_uid.value]
  }

  with "rules" {
    query = query.role_rules
    args  = [self.input.role_uid.value]
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
      base      = graph.role_resource_structure
      args = {
        role_uids = [self.input.role_uid.value]
      }

      node {
        base = node.role
        args = {
          role_uids = [self.input.role_uid.value]
        }
      }

      node {
        base = node.service_account
        args = {
          service_account_uids = with.service_accounts.rows[*].uid
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
        base = edge.service_account_to_role_binding
        args = {
          service_account_uids = with.service_accounts.rows[*].uid
        }
      }

      edge {
        base = edge.role_binding_to_role
        args = {
          role_uids = [self.input.role_uid.value]
        }
      }

      edge {
        base = edge.namespace_to_role_binding
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
        query = query.role_overview
        args = {
          uid = self.input.role_uid.value
        }
      }

      table {
        title = "Labels"
        width = 6
        query = query.role_labels
        args = {
          uid = self.input.role_uid.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Annotations"
        query = query.role_annotations
        args = {
          uid = self.input.role_uid.value
        }
      }

      table {
        title = "Rules"
        query = query.role_rules_detail
        args = {
          uid = self.input.role_uid.value
        }

      }

    }

  }

}

# Input queries

query "role_input" {
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

query "role_namespace" {
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

query "role_rules_count" {
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

query "role_rules" {
  sql = <<-EOQ
    select
      uid as uid
    from
      kubernetes_role,
      jsonb_array_elements(rules) as r
    where
      uid = $1;
  EOQ
}

query "role_service_accounts" {
  sql = <<-EOQ
    select
      a.uid as uid
    from
      kubernetes_service_account as a,
      kubernetes_role as r,
      kubernetes_role_binding as b,
      jsonb_array_elements(subjects) as s
    where
      b.role_name = r.name
      and s ->> 'kind' = 'ServiceAccount'
      and s ->> 'name' = a.name
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

query "role_overview" {
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

query "role_labels" {
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

query "role_annotations" {
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

query "role_rules_detail" {
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
