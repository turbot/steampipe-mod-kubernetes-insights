node "role" {
  category = category.role

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
      uid = any($1);
  EOQ

  param "role_uids" {}
}
