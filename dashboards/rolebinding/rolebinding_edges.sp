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
      and b.context_name = r.context_name
      and r.uid = any($1);
  EOQ

  param "role_uids" {}
}
