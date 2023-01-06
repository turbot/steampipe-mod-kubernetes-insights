dashboard "role_binding_detail" {

  title         = "Kubernetes Role Binding Detail"
  documentation = file("./dashboards/rolebinding/docs/rolebinding_detail.md")

  tags = merge(local.role_binding_common_tags, {
    type = "Detail"
  })

  input "role_binding_uid" {
    title = "Select a Role Binding:"
    query = query.role_binding_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.role_binding_subject_count
      args = {
        uid = self.input.role_binding_uid.value
      }
    }

    card {
      width = 2
      query = query.role_binding_kind
      args = {
        uid = self.input.role_binding_uid.value
      }
    }

    card {
      width = 2
      query = query.role_binding_namespace
      args = {
        uid = self.input.role_binding_uid.value
      }
    }

  }

  with "namespaces" {
    query = query.role_binding_namespaces
    args  = [self.input.role_binding_uid.value]
  }

  with "roles" {
    query = query.role_binding_roles
    args  = [self.input.role_binding_uid.value]
  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.role
        args = {
          role_uids = with.roles.rows[*].uid
        }
      }

      node {
        base = node.role_binding
        args = {
          role_binding_uids = [self.input.role_binding_uid.value]
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
          role_uids = with.roles.rows[*].uid
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
        query = query.role_binding_overview
        args = {
          uid = self.input.role_binding_uid.value
        }
      }

      table {
        title = "Labels"
        width = 6
        query = query.role_binding_labels
        args = {
          uid = self.input.role_binding_uid.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Annotations"
        query = query.role_binding_annotations
        args = {
          uid = self.input.role_binding_uid.value
        }
      }

      table {
        title = "Subjects"
        query = query.role_binding_subjects
        args = {
          uid = self.input.role_binding_uid.value
        }

      }

    }

  }

}

# Input queries

query "role_binding_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'context_name', context_name
      ) as tags
    from
      kubernetes_role_binding
    order by
      title;
  EOQ
}

# Card queries

query "role_binding_namespace" {
  sql = <<-EOQ
    select
      'Namespace' as label,
      initcap(namespace) as value,
      case when namespace = 'default' then 'alert' else 'ok' end as type
    from
      kubernetes_role_binding
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "role_binding_subject_count" {
  sql = <<-EOQ
    select
      'Subjects' as label,
      count(s) as value
    from
      kubernetes_role_binding,
      jsonb_array_elements(subjects) as s
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "role_binding_kind" {
  sql = <<-EOQ
    select
      'Role Kind' as label,
      role_kind as value
    from
      kubernetes_role_binding
    where
      uid = $1;
  EOQ

  param "uid" {}
}

# With queries

query "role_binding_namespaces" {
  sql = <<-EOQ
    select
      n.uid as uid
    from
      kubernetes_namespace as n,
      kubernetes_role_binding as b
    where
      n.name = b.namespace
      and b.uid = $1;
  EOQ
}

query "role_binding_roles" {
  sql = <<-EOQ
    select
      r.uid as uid
    from
      kubernetes_role_binding as b,
      kubernetes_role as r
    where
      r.name = b.role_name
      and b.uid = $1;
  EOQ
}

# Other queries

query "role_binding_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      creation_timestamp as "Create Time",
      resource_version as "Resource Version",
      context_name as "Context Name"
    from
      kubernetes_role_binding
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "role_binding_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_role_binding
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

query "role_binding_annotations" {
  sql = <<-EOQ
    with jsondata as (
   select
     annotations::json as annotation
   from
     kubernetes_role_binding
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

query "role_binding_subjects" {
  sql = <<-EOQ
    select
      s ->> 'kind' as "Kind",
      s ->> 'name' as "Name",
      s ->> 'apiGroup' as "API Group"
    from
      kubernetes_role_binding,
      jsonb_array_elements(subjects) as s
    where
      uid = $1;
  EOQ

  param "uid" {}
}
