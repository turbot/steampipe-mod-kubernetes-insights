dashboard "service_account_detail" {

  title         = "Kubernetes Service Account Detail"
  documentation = file("./dashboards/serviceaccount/docs/service_account_detail.md")

  tags = merge(local.service_account_common_tags, {
    type = "Detail"
  })

  input "service_account_uid" {
    title = "Select a service account:"
    query = query.service_account_input
    width = 4
  }

  container {

    card {
      width = 3
      query = query.service_account_default_namespace
      args = {
        uid = self.input.service_account_uid.value
      }
      href = "/kubernetes_insights.dashboard.namespace_detail?input.namespace_uid={{.'UID' | @uri}}"
    }

    card {
      width = 3
      query = query.service_account_automount_token
      args = {
        uid = self.input.service_account_uid.value
      }
    }

  }

  with "secrets_for_service_account" {
    query = query.secrets_for_service_account
    args  = [self.input.service_account_uid.value]
  }

  with "roles_for_service_account" {
    query = query.roles_for_service_account
    args  = [self.input.service_account_uid.value]
  }

  with "role_bindings_for_service_account" {
    query = query.role_bindings_for_service_account
    args  = [self.input.service_account_uid.value]
  }

  with "pods_for_service_account" {
    query = query.pods_for_service_account
    args  = [self.input.service_account_uid.value]
  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.pod
        args = {
          pod_uids = with.pods_for_service_account.rows[*].uid
        }
      }

      node {
        base = node.role
        args = {
          role_uids = with.roles_for_service_account.rows[*].uid
        }
      }

      node {
        base = node.role_binding
        args = {
          role_binding_uids = with.role_bindings_for_service_account.rows[*].uid
        }
      }

      node {
        base = node.secret
        args = {
          secret_uids = with.secrets_for_service_account.rows[*].uid
        }
      }

      node {
        base = node.service_account
        args = {
          service_account_uids = [self.input.service_account_uid.value]
        }
      }

      edge {
        base = edge.service_account_to_role_binding
        args = {
          service_account_uids = [self.input.service_account_uid.value]
        }
      }

      edge {
        base = edge.role_binding_to_role
        args = {
          role_uids = with.roles_for_service_account.rows[*].uid
        }
      }

      edge {
        base = edge.pod_to_service_account
        args = {
          pod_uids = with.pods_for_service_account.rows[*].uid
        }
      }

      edge {
        base = edge.service_account_to_secret
        args = {
          service_account_uids = [self.input.service_account_uid.value]
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
        query = query.service_account_overview
        args = {
          uid = self.input.service_account_uid.value
        }

        column "Namespace" {
          href = "/kubernetes_insights.dashboard.namespace_detail?input.namespace_uid={{.'Namespace UID' | @uri}}"
        }

        column "Namespace UID" {
          display = "none"
        }
      }

      table {
        title = "Labels"
        width = 6
        query = query.service_account_labels
        args = {
          uid = self.input.service_account_uid.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Annotations"
        query = query.service_account_annotations
        args = {
          uid = self.input.service_account_uid.value
        }
      }

    }

  }

}

# Input queries

query "service_account_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'context_name', context_name
      ) as tags
    from
      kubernetes_service_account
    order by
      title;
  EOQ
}

# Card queries

query "service_account_default_namespace" {
  sql = <<-EOQ
    select
      'Namespace' as label,
      initcap(namespace) as value,
      case when namespace = 'default' then 'alert' else 'ok' end as type,
      n.uid as "UID"
    from
      kubernetes_service_account as r,
      kubernetes_namespace as n
    where
      n.name = r.namespace
      and n.context_name = r.context_name
      and r.uid = $1;
  EOQ

  param "uid" {}
}

query "service_account_automount_token" {
  sql = <<-EOQ
    select
      'Automount Token' as label,
      initcap(automount_service_account_token::text) as value,
      case when automount_service_account_token then 'alert' else 'ok' end as type
    from
      kubernetes_service_account
    where
     uid = $1;
  EOQ

  param "uid" {}
}

# With queries

query "pods_for_service_account" {
  sql = <<-EOQ
    select
      p.uid as uid
    from
      kubernetes_service_account as s,
      kubernetes_pod as p
    where
      p.service_account_name = s.name
      and s.context_name = p.context_name
      and s.uid = $1;
  EOQ
}

query "roles_for_service_account" {
  sql = <<-EOQ
    select
      distinct r.uid as uid
    from
      kubernetes_service_account as a,
      kubernetes_role as r,
      kubernetes_role_binding as b,
      jsonb_array_elements(subjects) as s
    where
      b.role_name = r.name
      and s ->> 'kind' = 'ServiceAccount'
      and s ->> 'name' = a.name
      and a.context_name = r.context_name
      and a.uid = $1;
  EOQ
}

query "role_bindings_for_service_account" {
  sql = <<-EOQ
    select
      distinct b.uid as uid
    from
      kubernetes_service_account as a,
      kubernetes_role_binding as b,
      jsonb_array_elements(subjects) as s
    where
      s ->> 'kind' = 'ServiceAccount'
      and s ->> 'name' = a.name
      and a.context_name = b.context_name
      and a.uid = $1;
  EOQ
}

query "secrets_for_service_account" {
  sql = <<-EOQ
    select
      distinct s.uid as uid
    from
      kubernetes_secret as s,
      kubernetes_service_account as a,
      jsonb_array_elements(secrets) as se
    where
      se ->> 'name' = s.name
      and a.context_name = s.context_name
      and a.uid = $1;
  EOQ
}

# Other queries

query "service_account_overview" {
  sql = <<-EOQ
    select
      s.name as "Name",
      s.uid as "UID",
      s.creation_timestamp as "Create Time",
      s.resource_version as "Resource Version",
      n.uid as "Namespace UID",
      n.name as "Namespace",
      s.context_name as "Context Name"
    from
      kubernetes_service_account as s,
      kubernetes_namespace as n
    where
      n.name = s.namespace
      and n.context_name = s.context_name
      and s.uid = $1;
  EOQ

  param "uid" {}
}

query "service_account_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_service_account
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

query "service_account_annotations" {
  sql = <<-EOQ
    with jsondata as (
   select
     annotations::json as annotation
   from
     kubernetes_service_account
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

query "service_account_rules_detail" {
  sql = <<-EOQ
    select
      r -> 'verbs' as "Verbs",
      r -> 'apiGroups' as "API Groups",
      r -> 'resources' as "Resources",
      r -> 'resourceNames' as "Resource Names"
    from
      kubernetes_service_account,
      jsonb_array_elements(rules) as r
    where
      uid = $1;
  EOQ

  param "uid" {}
}
