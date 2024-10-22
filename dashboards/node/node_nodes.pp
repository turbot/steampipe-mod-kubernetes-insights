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

node "node_volume" {
  category = category.node_volume

  sql = <<-EOQ
    select
      v ->> 'name' as id,
      v ->> 'name' as title,
      jsonb_build_object(
        'Device Path', v ->> 'devicePath',
        'Context Name', context_name
      ) as properties
    from
      kubernetes_node,
      jsonb_array_elements(volumes_attached) as v
    where
      v ->> 'name' = any($1);
  EOQ

  param "volume_names" {}
}
