dashboard "cluster_role_detail" {

  title         = "Kubernetes Cluster Role Detail"
  documentation = file("./dashboards/clusterrole/docs/cluster_role_detail.md")

  tags = merge(local.cluster_role_common_tags, {
    type = "Detail"
  })

  input "cluster_role_uid" {
    title = "Select a ClusterRole:"
    query = query.cluster_role_input
    width = 4
  }

  container {

    card {
      width = 3
      query = query.cluster_role_rules_count
      args = {
        uid = self.input.cluster_role_uid.value
      }
    }
  }

  with "service_accounts_for_cluster_role" {
    query = query.service_accounts_for_cluster_role
    args  = [self.input.cluster_role_uid.value]
  }

  with "cluster_role_bindings_for_cluster_role" {
    query = query.cluster_role_bindings_for_cluster_role
    args  = [self.input.cluster_role_uid.value]
  }

  with "cluster_role_rules_for_cluster_role" {
    query = query.cluster_role_rules_for_cluster_role
    args  = [self.input.cluster_role_uid.value]
  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"
      base      = graph.cluster_role_resource_structure
      args = {
        cluster_role_uids = [self.input.cluster_role_uid.value]
      }

      node {
        base = node.cluster_role
        args = {
          cluster_role_uids = [self.input.cluster_role_uid.value]
        }
      }

      node {
        base = node.service_account
        args = {
          service_account_uids = with.service_accounts_for_cluster_role.rows[*].uid
        }
      }

      node {
        base = node.cluster_role_binding
        args = {
          cluster_role_binding_uids = with.cluster_role_bindings_for_cluster_role.rows[*].uid
        }
      }

      node {
        base = node.role_rule_verb_and_resource
        args = {
          rules = with.cluster_role_rules_for_cluster_role.rows[0].rules
        }
      }

      node {
        base = node.role_rule_resource_name
        args = {
          rules = with.cluster_role_rules_for_cluster_role.rows[0].rules
        }
      }

      edge {
        base = edge.role_rule_to_verb_and_resource
        args = {
          rules = with.cluster_role_rules_for_cluster_role.rows[0].rules
          uid   = self.input.cluster_role_uid.value
        }
      }


      edge {
        base = edge.role_rule_verb_and_resource_to_resource_name
        args = {
          rules = with.cluster_role_rules_for_cluster_role.rows[0].rules
        }
      }

      edge {
        base = edge.service_account_to_cluster_role_binding
        args = {
          service_account_uids = with.service_accounts_for_cluster_role.rows[*].uid
        }
      }

      edge {
        base = edge.cluster_role_binding_to_cluster_role
        args = {
          cluster_role_uids = [self.input.cluster_role_uid.value]
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
        query = query.cluster_role_overview
        args = {
          uid = self.input.cluster_role_uid.value
        }
      }

      table {
        title = "Labels"
        width = 6
        query = query.cluster_role_labels
        args = {
          uid = self.input.cluster_role_uid.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Annotations"
        query = query.cluster_role_annotations
        args = {
          uid = self.input.cluster_role_uid.value
        }
      }

      table {
        title = "Rules"
        query = query.cluster_role_rules_detail
        args = {
          uid = self.input.cluster_role_uid.value
        }

      }

    }

  }

}

# Input queries

query "cluster_role_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'context_name', context_name
      ) as tags
    from
      kubernetes_cluster_role
    order by
      title;
  EOQ
}

# Card queries

query "cluster_role_rules_count" {
  sql = <<-EOQ
    select
      'Rules' as label,
      count(r) as value
    from
      kubernetes_cluster_role,
      jsonb_array_elements(rules) as r
    where
      uid = $1;
  EOQ

  param "uid" {}
}

# With queries

query "service_accounts_for_cluster_role" {
  sql = <<-EOQ
    select
      a.uid as uid
    from
      kubernetes_service_account as a,
      kubernetes_cluster_role as r,
      kubernetes_cluster_role_binding as b,
      jsonb_array_elements(subjects) as s
    where
      b.role_name = r.name
      and s ->> 'kind' = 'ServiceAccount'
      and s ->> 'name' = a.name
      and a.context_name = r.context_name
      and r.uid = $1;
  EOQ
}

query "cluster_role_bindings_for_cluster_role" {
  sql = <<-EOQ
    select
      b.uid as uid
    from
      kubernetes_cluster_role_binding as b,
      kubernetes_cluster_role as r
    where
      r.name = b.role_name
      and b.context_name = r.context_name
      and r.uid = $1;
  EOQ
}

query "cluster_role_rules_for_cluster_role" {
  sql = <<-EOQ
    select
      coalesce(rules, '[]'::jsonb) as rules
    from
      kubernetes_cluster_role
    where
      uid = $1;
  EOQ
}

# Other queries

query "cluster_role_overview" {
  sql = <<-EOQ
    select
      r.name as "Name",
      r.uid as "UID",
      r.creation_timestamp as "Create Time",
      r.resource_version as "Resource Version",
      r.context_name as "Context Name"
    from
      kubernetes_cluster_role as r
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "cluster_role_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_cluster_role
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

query "cluster_role_annotations" {
  sql = <<-EOQ
    with jsondata as (
   select
     annotations::json as annotation
   from
     kubernetes_cluster_role
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

query "cluster_role_rules_detail" {
  sql = <<-EOQ
    select
      r -> 'verbs' as "Verbs",
      r -> 'apiGroups' as "API Groups",
      r -> 'resources' as "Resources",
      r -> 'resourceNames' as "Resource Names"
    from
      kubernetes_cluster_role,
      jsonb_array_elements(rules) as r
    where
      uid = $1;
  EOQ

  param "uid" {}
}
