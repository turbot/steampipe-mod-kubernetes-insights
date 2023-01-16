edge "role_binding_to_role" {
  title = "role"

  sql = <<-EOQ
     select
      b.uid as from_id,
      r.uid as to_id
    from
      kubernetes_role_binding as b,
      kubernetes_role as r
    where
      r.name = b.role_name
      and r.uid = any($1);
  EOQ

  param "role_uids" {}
}

edge "service_account_to_role_binding" {
  title = "role binding"

  sql = <<-EOQ
     select
      a.uid as from_id,
      b.uid as to_id
    from
      kubernetes_service_account as a,
      kubernetes_role_binding as b,
      jsonb_array_elements(subjects) as s
    where
      s ->> 'kind' = 'ServiceAccount'
      and s ->> 'name' = a.name
      and a.uid = any($1);
  EOQ

  param "service_account_uids" {}
}
