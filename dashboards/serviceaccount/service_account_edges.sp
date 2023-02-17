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
      and a.context_name = b.context_name
      and a.uid = any($1);
  EOQ

  param "service_account_uids" {}
}

edge "service_account_to_secret" {
  title = "secret"

  sql = <<-EOQ
     select
      a.uid as from_id,
      s.uid as to_id
    from
      kubernetes_secret as s,
      kubernetes_service_account as a,
      jsonb_array_elements(secrets) as se
    where
      se ->> 'name' = s.name
      and a.context_name = s.context_name
      and a.uid = any($1);
  EOQ

  param "service_account_uids" {}
}

edge "service_account_to_cluster_role_binding" {
  title = "cluster role binding"

  sql = <<-EOQ
     select
      a.uid as from_id,
      b.uid as to_id
    from
      kubernetes_service_account as a,
      kubernetes_cluster_role_binding as b,
      jsonb_array_elements(subjects) as s
    where
      s ->> 'kind' = 'ServiceAccount'
      and s ->> 'name' = a.name
      and a.context_name = b.context_name
      and a.uid = any($1);
  EOQ

  param "service_account_uids" {}
}
