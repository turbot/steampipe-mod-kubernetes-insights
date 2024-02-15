node "role" {
  category = category.role

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Creation Timestamp', creation_timestamp,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_role
    where
      uid = any($1);
  EOQ

  param "role_uids" {}
}

node "role_rule_resource_name" {
  category = category.role_rule_resource_name

  sql = <<-EOQ
    select
      concat('resource_name:',resource_name) as id,
      resource_name as title
    from
      jsonb_array_elements($1 :: jsonb) as rule,
      jsonb_array_elements_text(rule -> 'verbs') as verb,
      jsonb_array_elements_text(rule -> 'resources') as resource,
      jsonb_array_elements_text(coalesce(rule -> 'resourceNames', '["*"]'::jsonb)) as resource_name
  EOQ

  param "rules" {}
}

node "role_rule_verb_and_resource" {
  category = category.role_rule_verb

  sql = <<-EOQ
    select
      concat('verb:',verb,':resource:',resource) as id,
      concat(verb,':',resource) as title,
      jsonb_build_object(
        'apiGroups', rule -> 'apiGroups'
      ) as properties
    from
      jsonb_array_elements($1 :: jsonb) as rule,
      jsonb_array_elements_text(rule -> 'verbs') as verb,
      jsonb_array_elements_text(rule -> 'resources') as resource
  EOQ

  param "rules" {}
}
