dashboard "rbac_detail" {

  title         = "Kubernetes RBAC Detail"
  documentation = file("./dashboards/rbac/docs/rbac_detail.md")

  tags = merge(local.rbac_common_tags, {
    type = "Detail"
  })

  input "verb" {
    title = "Select verb(s):"
    type  = "multiselect"
    query = query.kubernetes_cluster_verbs
    width = 6
  }

  input "resource" {
    title = "Select resource(s):"
    type  = "multiselect"
    query = query.kubernetes_cluster_resources
    width = 6
  }

  with "service_accounts_for_rbac" {
    query = query.service_accounts_for_rbac
    args = {
      verb     = self.input.verb.value
      resource = self.input.resource.value
    }
  }

  with "role_bindings_for_rbac" {
    query = query.role_bindings_for_rbac
    args = {
      verb     = self.input.verb.value
      resource = self.input.resource.value
    }
  }

  with "roles_for_rbac" {
    query = query.roles_for_rbac
    args = {
      verb     = self.input.verb.value
      resource = self.input.resource.value
    }
  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"
      base      = graph.rbac_resource_structure
      args = {
        rbac_role_uids = with.roles_for_rbac.rows[*].uid
      }

      node {
        base = node.cluster_role
        args = {
          cluster_role_uids = with.roles_for_rbac.rows[*].uid
        }
      }

      node {
        base = node.role
        args = {
          role_uids = with.roles_for_rbac.rows[*].uid
        }
      }


      node {
        base = node.service_account
        args = {
          service_account_uids = with.service_accounts_for_rbac.rows[*].uid
        }
      }

      node {
        base = node.role_binding
        args = {
          role_binding_uids = with.role_bindings_for_rbac.rows[*].uid
        }
      }

      node {
        base = node.cluster_role_binding
        args = {
          cluster_role_binding_uids = with.role_bindings_for_rbac.rows[*].uid
        }
      }

      node {
        base = node.rbac_rule_verb_and_resource
        args = {
          rbac_role_uids = with.roles_for_rbac.rows[*].uid
          rbac_verbs     = self.input.verb.value
          rbac_resources = self.input.resource.value
        }
      }

      node {
        base = node.rbac_rule_resource_name
        args = {
          rbac_role_uids = with.roles_for_rbac.rows[*].uid
          rbac_resources = self.input.resource.value
        }
      }

      edge {
        base = edge.rbac_rule_to_verb_and_resource
        args = {
          rbac_role_uids = with.roles_for_rbac.rows[*].uid
        }
      }

      edge {
        base = edge.rbac_rule_verb_and_resource_to_resource_name
        args = {
          rbac_role_uids = with.roles_for_rbac.rows[*].uid
          rbac_resources = self.input.resource.value
        }
      }

      edge {
        base = edge.service_account_to_cluster_role_binding
        args = {
          service_account_uids = with.service_accounts_for_rbac.rows[*].uid
        }
      }

      edge {
        base = edge.cluster_role_binding_to_cluster_role
        args = {
          cluster_role_uids = with.roles_for_rbac.rows[*].uid
        }
      }

      edge {
        base = edge.service_account_to_role_binding
        args = {
          service_account_uids = with.service_accounts_for_rbac.rows[*].uid
        }
      }

      edge {
        base = edge.role_binding_to_role
        args = {
          role_uids = with.roles_for_rbac.rows[*].uid
        }
      }
    }
  }
}

# With queries

query "roles_for_rbac" {
  sql = <<-EOQ
    select
      distinct role.uid as uid
    from
      kubernetes_cluster_role_binding as b,
      kubernetes_cluster_role as role,
      kubernetes_service_account as a,
      jsonb_array_elements(subjects) as s,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements_text(r -> 'resources') as re,
      jsonb_array_elements_text(r -> 'verbs') as v
    where
      role.name = b.role_name
      and (s ->> 'kind' <> 'ServiceAccount' or s ->> 'name' in (select name from kubernetes_service_account))
      and b.context_name = role.context_name
      and v in (select unnest (string_to_array($1, ',')::text[]))
      and re in (select unnest (string_to_array($2, ',')::text[]))
    union
    select
      distinct role.uid as uid
    from
      kubernetes_role_binding as b,
      kubernetes_role as role,
      kubernetes_service_account as a,
      jsonb_array_elements(subjects) as s,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements_text(r -> 'resources') as re,
      jsonb_array_elements_text(r -> 'verbs') as v
    where
      role.name = b.role_name
      and (s ->> 'kind' <> 'ServiceAccount' or s ->> 'name' in (select name from kubernetes_service_account))
      and b.context_name = role.context_name
      and v in (select unnest (string_to_array($1, ',')::text[]))
      and re in (select unnest (string_to_array($2, ',')::text[]))
  EOQ

  param "verb" {}
  param "resource" {}
}

query "kubernetes_cluster_verbs" {
  sql = <<-EOQ
    select
      distinct verb as label,
      verb as value,
      verb
    from
      kubernetes_role,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements_text(r->'verbs') as verb
    union
    select
      distinct verb as label,
      verb as value,
      verb
    from
      kubernetes_cluster_role,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements_text(r->'verbs') as verb
    order by
      verb;
  EOQ
}

query "kubernetes_cluster_resources" {
  sql = <<-EOQ
    select
      distinct resource as label,
      resource as value,
      resource
    from
      kubernetes_role,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements_text(r->'resources') as resource
    union
    select
      distinct resource as label,
      resource as value,
      resource
    from
      kubernetes_cluster_role,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements_text(r->'resources') as resource
    order by
      resource;
  EOQ
}

query "service_accounts_for_rbac" {
  sql = <<-EOQ
    with rbac_role_input as (
     select
      distinct role.uid as uid
    from
      kubernetes_role_binding as b,
      kubernetes_role as role,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements_text(r -> 'resources') as re,
      jsonb_array_elements_text(r -> 'verbs') as v
    where
      role.name = b.role_name
      and b.context_name = role.context_name
      and v in (select unnest (string_to_array($1, ',')::text[]))
      and re in (select unnest (string_to_array($2, ',')::text[]))
    union
    select
      distinct role.uid as uid
    from
      kubernetes_cluster_role_binding as b,
      kubernetes_cluster_role as role,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements_text(r -> 'resources') as re,
      jsonb_array_elements_text(r -> 'verbs') as v
    where
      role.name = b.role_name
      and b.context_name = role.context_name
      and v in (select unnest (string_to_array($1, ',')::text[]))
      and re in (select unnest (string_to_array($2, ',')::text[]))
    )
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
      and r.uid in (select uid from rbac_role_input)
    union
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
      and a.context_name = r.context_name
      and r.uid in (select uid from rbac_role_input);
  EOQ

  param "verb" {}
  param "resource" {}
}

query "role_bindings_for_rbac" {
  sql = <<-EOQ
    with rbac_role_input as (
    select
      distinct role.uid as uid
    from
      kubernetes_cluster_role_binding as b,
      kubernetes_cluster_role as role,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements_text(r -> 'resources') as re,
      jsonb_array_elements_text(r -> 'verbs') as v
    where
      role.name = b.role_name
      and b.context_name = role.context_name
      and v in (select unnest (string_to_array($1, ',')::text[]))
      and re in (select unnest (string_to_array($2, ',')::text[]))
    union
    select
      distinct role.uid as uid
    from
      kubernetes_role_binding as b,
      kubernetes_role as role,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements_text(r -> 'resources') as re,
      jsonb_array_elements_text(r -> 'verbs') as v
    where
      role.name = b.role_name
      and b.context_name = role.context_name
      and v in (select unnest (string_to_array($1, ',')::text[]))
      and re in (select unnest (string_to_array($2, ',')::text[]))
    )
    select
      b.uid as uid
    from
      kubernetes_cluster_role as r,
      kubernetes_cluster_role_binding as b,
      kubernetes_service_account as a,
      jsonb_array_elements(subjects) as s
    where
      r.name = b.role_name
      and (s ->> 'kind' <> 'ServiceAccount' or s ->> 'name' in (select name from kubernetes_service_account))
      and b.context_name = r.context_name
      and r.uid in (select uid from rbac_role_input)
    union
    select
      b.uid as uid
    from
      kubernetes_role_binding as b,
      kubernetes_role as r,
      kubernetes_service_account as a,
      jsonb_array_elements(subjects) as s
    where
      r.name = b.role_name
      and (s ->> 'kind' <> 'ServiceAccount' or s ->> 'name' in (select name from kubernetes_service_account))
      and b.context_name = r.context_name
      and r.uid in (select uid from rbac_role_input);
  EOQ

  param "verb" {}
  param "resource" {}
}

# Other queries



