edge "role_to_rolebinding" {
  title = "role binding"

  sql = <<-EOQ
     select
      r.uid as from_id,
      b.uid as to_id
    from
      kubernetes_role_binding as b,
      kubernetes_role as r
    where
      r.name = b.role_name
      and r.uid = any($1);
  EOQ

  param "role_uids" {}
}
