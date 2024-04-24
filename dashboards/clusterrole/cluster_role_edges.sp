edge "cluster_role_binding_to_cluster_role" {
  title = "cluster role"

  sql = <<-EOQ
    select
      b.uid as from_id,
      r.uid as to_id
    from
      kubernetes_cluster_role_binding as b
    join
      kubernetes_cluster_role as r on r.name = b.role_name
    join
      unnest($1::text[]) as u on r.uid = split_part(u, '/', 1)
      and b.context_name = split_part(u, '/', 2);
  EOQ
 
  param "cluster_role_uids" {}
}
