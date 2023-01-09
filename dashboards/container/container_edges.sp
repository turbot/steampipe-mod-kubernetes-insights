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
