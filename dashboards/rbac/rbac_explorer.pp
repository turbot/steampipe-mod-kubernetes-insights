dashboard "rbac_explorer" {

  title         = "Kubernetes RBAC Explorer"
  documentation = file("./dashboards/rbac/docs/rbac_explorer.md")

  tags = merge(local.rbac_common_tags, {
    type = "Report"
  })

  input "cluster_context" {
    title = "Select a cluster:"
    query = query.cluster_input
    width = 4
  }

  input "verb" {
    title = "Select verb(s):"
    type  = "multiselect"
    query = query.kubernetes_cluster_verbs
    width = 4
    args = {
      cluster_context = self.input.cluster_context.value
    }
  }

  input "resource" {
    title = "Select resource(s):"
    type  = "multiselect"
    query = query.kubernetes_cluster_resources
    width = 4
    args = {
      cluster_context = self.input.cluster_context.value
    }
  }

  with "service_accounts_for_rbac" {
    query = query.service_accounts_for_rbac
    args = {
      verb            = self.input.verb.value
      resource        = self.input.resource.value
      cluster_context = self.input.cluster_context.value
    }
  }

  with "role_bindings_for_rbac" {
    query = query.role_bindings_for_rbac
    args = {
      verb            = self.input.verb.value
      resource        = self.input.resource.value
      cluster_context = self.input.cluster_context.value
    }
  }

  with "roles_for_rbac" {
    query = query.roles_for_rbac
    args = {
      verb            = self.input.verb.value
      resource        = self.input.resource.value
      cluster_context = self.input.cluster_context.value
    }
  }

  container {
    graph {
      title     = "Kubernetes RBAC Explorer"
      type      = "graph"
      direction = "TD"
      base      = graph.rbac_resource_structure
      args = {
        rbac_role_uids            = with.roles_for_rbac.rows[*].uid
        cluster_role_uids         = with.roles_for_rbac.rows[*].uid
        role_uids                 = with.roles_for_rbac.rows[*].uid
        service_account_uids      = with.service_accounts_for_rbac.rows[*].uid
        role_binding_uids         = with.role_bindings_for_rbac.rows[*].uid
        cluster_role_binding_uids = with.role_bindings_for_rbac.rows[*].uid
        rbac_verbs                = self.input.verb.value
        rbac_resources            = self.input.resource.value
      }

    }
  }

  container {

    table {
      title = "RBAC Analysis"
      query = query.rbac_rule_analysis
      args = {
        verb            = self.input.verb.value
        resource        = self.input.resource.value
        cluster_context = self.input.cluster_context.value
      }

    }

  }
}

# With queries
query "rbac_rule_analysis" {
  sql = <<-EOQ
    select
      s ->> 'name' as "Principal",
      s ->> 'kind' as "Principal Kind",
      b.name as "Role Binding",
      role.name as "Role",
      v as "Verbs",
      re as "Resources",
      resource_name as "Resource Names"
    from
      kubernetes_cluster_role_binding as b,
      kubernetes_cluster_role as role,
      kubernetes_service_account as a,
      jsonb_array_elements(subjects) as s,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements_text(r -> 'resources') as re,
      jsonb_array_elements_text(r -> 'verbs') as v,
      jsonb_array_elements_text(coalesce(r -> 'resourceNames', '["*"]'::jsonb)) as resource_name
    where
      role.name = b.role_name
      and (s ->> 'kind' <> 'ServiceAccount' or s ->> 'name' in (select name from kubernetes_service_account))
      and b.context_name = role.context_name
      and (v in (select unnest (string_to_array($1, ',')::text[])) or v = '*')
      and (re in (select unnest (string_to_array($2, ',')::text[])) or re = '*')
      and b.context_name in (select unnest (string_to_array($3, ',')::text[]))
    union
    select
      s ->> 'name' as "Principal",
      s ->> 'kind' as "Principal Kind",
      b.name as "Role Binding",
      role.name as "Role",
      v as "Verbs",
      re as "Resources",
      resource_name as "Resource Names"
    from
      kubernetes_role_binding as b,
      kubernetes_role as role,
      kubernetes_service_account as a,
      jsonb_array_elements(subjects) as s,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements_text(r -> 'resources') as re,
      jsonb_array_elements_text(r -> 'verbs') as v,
      jsonb_array_elements_text(coalesce(r -> 'resourceNames', '["*"]'::jsonb)) as resource_name
    where
      role.name = b.role_name
      and (s ->> 'kind' <> 'ServiceAccount' or s ->> 'name' in (select name from kubernetes_service_account))
      and b.context_name = role.context_name
      and (v in (select unnest (string_to_array($1, ',')::text[])) or v = '*')
      and (re in (select unnest (string_to_array($2, ',')::text[])) or re = '*')
      and b.context_name in (select unnest (string_to_array($3, ',')::text[]))
    order by
      1;
  EOQ

  param "verb" {}
  param "resource" {}
  param "cluster_context" {}
}

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
      and (v in (select unnest (string_to_array($1, ',')::text[])) or v = '*')
      and (re in (select unnest (string_to_array($2, ',')::text[])) or re = '*')
      and b.context_name in (select unnest (string_to_array($3, ',')::text[]))
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
      and (v in (select unnest (string_to_array($1, ',')::text[])) or v = '*')
      and (re in (select unnest (string_to_array($2, ',')::text[])) or re = '*')
      and b.context_name in (select unnest (string_to_array($3, ',')::text[]))
  EOQ

  param "verb" {}
  param "resource" {}
  param "cluster_context" {}
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
    where
      context_name in (select unnest (string_to_array($1, ',')::text[]))
    union
    select
      distinct verb as label,
      verb as value,
      verb
    from
      kubernetes_cluster_role,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements_text(r->'verbs') as verb
    where
      context_name in (select unnest (string_to_array($1, ',')::text[]))
    order by
      verb;
  EOQ

  param "cluster_context" {}
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
    where
      context_name in (select unnest (string_to_array($1, ',')::text[]))
    union
    select
      distinct resource as label,
      resource as value,
      resource
    from
      kubernetes_cluster_role,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements_text(r->'resources') as resource
    where
      context_name in (select unnest (string_to_array($1, ',')::text[]))
    order by
      resource;
  EOQ

  param "cluster_context" {}
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
      and (v in (select unnest (string_to_array($1, ',')::text[])) or v = '*')
      and (re in (select unnest (string_to_array($2, ',')::text[])) or re = '*')
      and b.context_name in (select unnest (string_to_array($3, ',')::text[]))
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
      and (v in (select unnest (string_to_array($1, ',')::text[])) or v = '*')
      and (re in (select unnest (string_to_array($2, ',')::text[])) or re = '*')
      and b.context_name in (select unnest (string_to_array($3, ',')::text[]))
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
  param "cluster_context" {}
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
      and (v in (select unnest (string_to_array($1, ',')::text[])) or v = '*')
      and (re in (select unnest (string_to_array($2, ',')::text[])) or re = '*')
      and b.context_name in (select unnest (string_to_array($3, ',')::text[]))
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
      and (v in (select unnest (string_to_array($1, ',')::text[])) or v = '*')
      and (re in (select unnest (string_to_array($2, ',')::text[])) or re = '*')
      and b.context_name in (select unnest (string_to_array($3, ',')::text[]))
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
  param "cluster_context" {}
}




