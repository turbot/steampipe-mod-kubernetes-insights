edge "cluster_role_binding_to_cluster_role" {
  title = "cluster role"

  sql = <<-EOQ
     select
      b.uid as from_id,
      r.uid as to_id
    from
      kubernetes_cluster_role_binding as b,
      kubernetes_cluster_role as r
    where
      r.name = b.role_name
      and r.context_name = b.context_name
      and r.uid = any($1);
  EOQ

  param "cluster_role_uids" {}
}
