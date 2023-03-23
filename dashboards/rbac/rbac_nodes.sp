node "rbac_rule_verb_and_resource" {
  category = category.role_rule_verb

  sql = <<-EOQ
    with verb_resource as (
    select
      concat('verb:',verb,':resource:',resource,coalesce(rule -> 'resourceNames', '["*"]'::jsonb)) as id,
      concat(verb,':',resource) as title,
      verb,
      resource,
      jsonb_build_object(
        'apiGroups', rule -> 'apiGroups'
      ) as properties
    from
      kubernetes_role,
      jsonb_array_elements(rules) as rule,
      jsonb_array_elements_text(rule -> 'verbs') as verb,
      jsonb_array_elements_text(rule -> 'resources') as resource
    where
      uid = any($1)
    union
    select
      concat('verb:',verb,':resource:',resource,coalesce(rule -> 'resourceNames', '["*"]'::jsonb)) as id,
      concat(verb,':',resource) as title,
      verb,
      resource,
      jsonb_build_object(
        'apiGroups', rule -> 'apiGroups'
      ) as properties
    from
      kubernetes_cluster_role,
      jsonb_array_elements(rules) as rule,
      jsonb_array_elements_text(rule -> 'verbs') as verb,
      jsonb_array_elements_text(rule -> 'resources') as resource
    where
      uid = any($1)
    )
    select
      id,
      title,
      properties
    from
      verb_resource
    where
      (verb in (select unnest (string_to_array($2, ',')::text[])) or verb = '*')
      and (resource in (select unnest (string_to_array($3, ',')::text[])) or resource = '*');
  EOQ

  param "rbac_role_uids" {}
  param "rbac_verbs" {}
  param "rbac_resources" {}
}

node "rbac_rule_resource_name" {
  category = category.role_rule_resource_name

  sql = <<-EOQ
    select
      concat('resource_name:',resource_name) as id,
      resource_name as title
    from
      kubernetes_cluster_role,
      jsonb_array_elements(rules) as rule,
      jsonb_array_elements_text(rule -> 'verbs') as verb,
      jsonb_array_elements_text(rule -> 'resources') as resource,
      jsonb_array_elements_text(coalesce(rule -> 'resourceNames', '["*"]'::jsonb)) as resource_name
    where
      uid = any($1)
      and (verb in (select unnest (string_to_array($2, ',')::text[])) or verb = '*')
      and (resource in (select unnest (string_to_array($3, ',')::text[])) or resource = '*')
    union
    select
      concat('resource_name:',resource_name) as id,
      resource_name as title
    from
      kubernetes_role,
      jsonb_array_elements(rules) as rule,
      jsonb_array_elements_text(rule -> 'verbs') as verb,
      jsonb_array_elements_text(rule -> 'resources') as resource,
      jsonb_array_elements_text(coalesce(rule -> 'resourceNames', '["*"]'::jsonb)) as resource_name
    where
      uid = any($1)
      and (verb in (select unnest (string_to_array($2, ',')::text[])) or verb = '*')
      and (resource in (select unnest (string_to_array($3, ',')::text[])) or resource = '*')
  EOQ

  param "rbac_role_uids" {}
  param "rbac_verbs" {}
  param "rbac_resources" {}
}
