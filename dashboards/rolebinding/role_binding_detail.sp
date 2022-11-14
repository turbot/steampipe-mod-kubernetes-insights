dashboard "kubernetes_role_binding_detail" {

  title         = "Kubernetes Role Binding Detail"
  documentation = file("./dashboards/rolebinding/docs/role_binding_detail.md")

  tags = merge(local.role_binding_common_tags, {
    type = "Detail"
  })

  input "role_binding_uid" {
    title = "Select a Role Binding:"
    query = query.kubernetes_role_binding_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kubernetes_role_binding_subject_count
      args = {
        uid = self.input.role_binding_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_role_binding_kind
      args = {
        uid = self.input.role_binding_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_role_binding_namespace
      args = {
        uid = self.input.role_binding_uid.value
      }
    }

  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "LR"

      nodes = [
        node.kubernetes_role_binding_node,
        node.kubernetes_role_binding_from_namespace_node,
        node.kubernetes_role_binding_from_role_node
      ]

      edges = [
        edge.kubernetes_role_binding_from_namespace_edge,
        edge.kubernetes_role_binding_from_role_edge
      ]

      args = {
        uid = self.input.role_binding_uid.value
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
        query = query.kubernetes_role_binding_overview
        args = {
          uid = self.input.role_binding_uid.value
        }
      }

      table {
        title = "Labels"
        width = 6
        query = query.kubernetes_role_binding_labels
        args = {
          uid = self.input.role_binding_uid.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Annotations"
        query = query.kubernetes_role_binding_annotations
        args = {
          uid = self.input.role_binding_uid.value
        }
      }

      table {
        title = "Subjects"
        query = query.kubernetes_role_binding_subjects
        args = {
          uid = self.input.role_binding_uid.value
        }

      }

    }

  }

}

category "kubernetes_role_binding_no_link" {
  icon = local.kubernetes_rolebinding_icon
}

node "kubernetes_role_binding_node" {
  category = category.kubernetes_role_binding_no_link

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_role_binding
    where
      uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_role_binding_from_role_node" {
  category = category.kubernetes_role

  sql = <<-EOQ
    select
      r.uid as id,
      r.title as title,
      jsonb_build_object(
        'UID', r.uid,
        'Context Name', r.context_name
      ) as properties
    from
      kubernetes_role_binding as b,
      kubernetes_role as r
    where
      r.name = b.role_name
      and b.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_role_binding_from_role_edge" {
  title = "role binding"

  sql = <<-EOQ
     select
      r.uid as from_id,
      b.uid as to_id
    from
      kubernetes_role_binding as b,
      kubernetes_role as r
    where
      r.name = b.role_name
      and b.uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_role_binding_from_namespace_node" {
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
      kubernetes_namespace as n,
      kubernetes_role_binding as b
    where
      n.name = b.namespace
      and b.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_role_binding_from_namespace_edge" {
  title = "role binding"

  sql = <<-EOQ
     select
      n.uid as from_id,
      b.uid as to_id
    from
      kubernetes_namespace as n,
      kubernetes_role_binding as b
    where
      n.name = b.namespace
      and b.uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_role_binding_input" {
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

query "kubernetes_role_binding_namespace" {
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

query "kubernetes_role_binding_subject_count" {
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

query "kubernetes_role_binding_kind" {
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

query "kubernetes_role_binding_overview" {
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

query "kubernetes_role_binding_labels" {
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

query "kubernetes_role_binding_annotations" {
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

query "kubernetes_role_binding_subjects" {
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
