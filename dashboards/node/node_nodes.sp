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

node "volume" {
  category = category.volume

  sql = <<-EOQ
    select
      v ->> 'Name' as id,
      v ->> 'Name' as title,
      jsonb_build_object(
        'Device Path', v ->> 'DevicePath',
        'Context Name', context_name
      ) as properties
    from
      kubernetes_node,
      jsonb_array_elements(volumes_attached) as v
    where
      v ->> 'Name' = any($1);
  EOQ

  param "volume_names" {}
}
