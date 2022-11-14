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

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "LR"

      nodes = [
        node.kubernetes_role_node,
        node.kubernetes_role_from_namespace_node,
        node.kubernetes_role_to_rolebinding_node
      ]

      edges = [
        edge.kubernetes_role_from_namespace_edge,
        edge.kubernetes_role_to_rolebinding_edge
      ]

      args = {
        uid = self.input.role_uid.value
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

category "kubernetes_role_no_link" {
  icon = local.kubernetes_role_icon
}

node "kubernetes_role_node" {
  category = category.kubernetes_role_no_link

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_role
    where
      uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_role_to_rolebinding_node" {
  category = category.kubernetes_rolebinding

  sql = <<-EOQ
    select
      b.uid as id,
      b.title as title,
      jsonb_build_object(
        'UID', b.uid,
        'Context Name', b.context_name
      ) as properties
    from
      kubernetes_role_binding as b,
      kubernetes_role as r
    where
      r.name = b.role_name
      and r.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_role_to_rolebinding_edge" {
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
      and r.uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_role_from_namespace_node" {
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
      kubernetes_role as r
    where
      n.name = r.namespace
      and r.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_role_from_namespace_edge" {
  title = "role"

  sql = <<-EOQ
     select
      n.uid as from_id,
      r.uid as to_id
    from
      kubernetes_namespace as n,
      kubernetes_role as r
    where
      n.name = r.namespace
      and r.uid = $1;
  EOQ

  param "uid" {}
}

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
