edge "rbac_rule_to_verb_and_resource" {
  title = "action"

  sql = <<-EOQ
    select
      concat('verb:',verb,':resource:',resource,coalesce(rule -> 'resourceNames', '["*"]'::jsonb)) as to_id,
      uid as from_id
    from
      kubernetes_role,
      jsonb_array_elements(rules) as rule,
      jsonb_array_elements_text(rule -> 'verbs') as verb,
      jsonb_array_elements_text(rule -> 'resources') as resource
    where
       uid = any($1)
    union
    select
      concat('verb:',verb,':resource:',resource,coalesce(rule -> 'resourceNames', '["*"]'::jsonb)) as to_id,
      uid as from_id
    from
      kubernetes_cluster_role,
      jsonb_array_elements(rules) as rule,
      jsonb_array_elements_text(rule -> 'verbs') as verb,
      jsonb_array_elements_text(rule -> 'resources') as resource
    where
       uid = any($1);
  EOQ

  param "rbac_role_uids" {}
}

edge "rbac_rule_verb_and_resource_to_resource_name" {
  title = "resource"

  sql = <<-EOQ
    select
      concat('resource_name:',resource_name) as to_id,
      concat('verb:',verb,':resource:',resource,coalesce(rule -> 'resourceNames', '["*"]'::jsonb)) as from_id
    from
      kubernetes_cluster_role,
      jsonb_array_elements(rules) as rule,
      jsonb_array_elements_text(rule -> 'verbs') as verb,
      jsonb_array_elements_text(rule -> 'resources') as resource,
      jsonb_array_elements_text(coalesce(rule -> 'resourceNames', '["*"]'::jsonb)) as resource_name
    where
      uid = any($1)
      and resource in (select unnest (string_to_array($2, ',')::text[]))
    union
    select
      concat('resource_name:',resource_name) as to_id,
      concat('verb:',verb,':resource:',resource,coalesce(rule -> 'resourceNames', '["*"]'::jsonb)) as from_id
    from
      kubernetes_role,
      jsonb_array_elements(rules) as rule,
      jsonb_array_elements_text(rule -> 'verbs') as verb,
      jsonb_array_elements_text(rule -> 'resources') as resource,
      jsonb_array_elements_text(coalesce(rule -> 'resourceNames', '["*"]'::jsonb)) as resource_name
    where
      uid = any($1)
      and resource in (select unnest (string_to_array($2, ',')::text[]));
  EOQ

  param "rbac_role_uids" {}
  param "rbac_resources" {}
}
