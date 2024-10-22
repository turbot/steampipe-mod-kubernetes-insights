edge "role_rule_to_verb_and_resource" {
  title = "action"

  sql = <<-EOQ
    select
      concat('verb:',verb,':resource:',resource) as to_id,
      $2 as from_id
    from
      jsonb_array_elements($1 :: jsonb) as rule,
      jsonb_array_elements_text(rule -> 'verbs') as verb,
      jsonb_array_elements_text(rule -> 'resources') as resource
  EOQ

  param "rules" {}
  param "uid" {}
}


edge "role_rule_verb_and_resource_to_resource_name" {
  title = "resource"

  sql = <<-EOQ
    select
      concat('resource_name:',resource_name) as to_id,
      concat('verb:',verb,':resource:',resource) as from_id
    from
      jsonb_array_elements($1 :: jsonb) as rule,
      jsonb_array_elements_text(rule -> 'verbs') as verb,
      jsonb_array_elements_text(rule -> 'resources') as resource,
      jsonb_array_elements_text(coalesce(rule -> 'resourceNames', '["*"]'::jsonb)) as resource_name
  EOQ

  param "rules" {}
}
