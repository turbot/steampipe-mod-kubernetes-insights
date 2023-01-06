node "node" {
  category = category.node

  sql = <<-EOQ
    select
      uid as id,
      name as title,
      jsonb_build_object(
        'UID', uid,
        'Phase', phase,
        'POD CIDR', pod_cidr,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_node
    where
      uid = any($1);
  EOQ

  param "node_uids" {}
}
