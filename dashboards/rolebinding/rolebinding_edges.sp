edge "role_binding_to_role" {
  title = "role"

  sql = <<-EOQ
     select
      b.uid as from_id,
      r.uid as to_id
    from
      kubernetes_role_binding as b
    join
      kubernetes_role as r on r.name = b.role_name
    join
      unnest($1::text[]) as u on r.uid = split_part(u, '/', 1)
      and b.context_name = split_part(u, '/', 2);
  EOQ

  param "role_uids" {}
}
