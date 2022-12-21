node "role_binding" {
  category = category.role_binding

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_role_binding
    where
      uid = any($1);
  EOQ

  param "role_binding_uids" {}
}
