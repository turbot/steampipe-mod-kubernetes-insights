edge "daemonset_to_node" {
  title = "node"

  sql = <<-EOQ
     select
      pod_owner ->> 'uid' as from_id,
      n.uid as to_id
    from
      kubernetes_node as n,
      kubernetes_pod as p,
      jsonb_array_elements(p.owner_references) as pod_owner
    where
      n.name = p.node_name
      and pod_owner ->> 'uid' = any($1);
  EOQ

  param "daemonset_uids" {}
}
