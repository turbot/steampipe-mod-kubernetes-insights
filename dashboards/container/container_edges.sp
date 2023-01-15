edge "container_to_node" {
  title = "node"

  sql = <<-EOQ
    select
      container ->> 'name' || pod.name as from_id,
      n.uid as to_id
    from
      kubernetes_node as n,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.containers) as container
    where
      n.name = pod.node_name
      and container ->> 'name' || pod.name = any($1);
  EOQ

  param "container_names" {}
}

edge "container_to_container_volume" {
  title = "volume"

  sql = <<-EOQ
    select
      c ->> 'name' || pod.name as from_id,
      v ->> 'name' || (c ->> 'name') as to_id
    from
      kubernetes_pod as pod,
      jsonb_array_elements(containers) as c,
      jsonb_array_elements(c -> 'volumeMounts') as v
    where
      concat(c ->> 'name',name) = any($1);
  EOQ

  param "container_names" {}
}

edge "container_volume_to_container_volume_mount_path" {
  title = "volume mount path"

  sql = <<-EOQ
    select
      v ->> 'name' || (c ->> 'name') as from_id,
      v ->> 'mountPath' || (c ->> 'name') as to_id
    from
      kubernetes_pod as pod,
      jsonb_array_elements(containers) as c,
      jsonb_array_elements(c -> 'volumeMounts') as v
    where
      concat(c ->> 'name',name) = any($1);
  EOQ

  param "container_names" {}
}
