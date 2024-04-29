edge "service_account_to_role_binding" {
  title = "role binding"

  sql = <<-EOQ
    select
      a.uid as from_id,
      b.uid as to_id
    from
      kubernetes_role_binding as b
    join
      jsonb_array_elements(subjects) as s on s ->> 'kind' = 'ServiceAccount'
    join
      kubernetes_service_account as a on s ->> 'name' = a.name
    join
      unnest($1::text[]) as u on b.context_name = split_part(u, '/', 2)
      and a.uid = split_part(u, '/', 1);
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
      kubernetes_service_account as a
    cross join lateral jsonb_array_elements(secrets) as se
    join
      kubernetes_secret as s on se ->> 'name' = s.name
    join
      unnest($1::text[]) as u on s.context_name = split_part(u, '/', 2)
      and a.uid = split_part(u, '/', 1);
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
      kubernetes_cluster_role_binding as b
    join
      jsonb_array_elements(subjects) as s on s ->> 'kind' = 'ServiceAccount'
    join
      kubernetes_service_account as a on s ->> 'name' = a.name
    join
      unnest($1::text[]) as u on b.context_name = split_part(u, '/', 2)
      and a.uid = split_part(u, '/', 1);
  EOQ

  param "service_account_uids" {}
}
