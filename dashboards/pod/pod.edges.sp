edge "pod_to_container" {
  title = "container"

  sql = <<-EOQ
     select
      p.uid as from_id,
      container ->> 'name' || p.name as to_id
    from
      kubernetes_pod as p,
      jsonb_array_elements(p.containers) as container
    where
      uid = any($1);
  EOQ

  param "pod_uids" {}
}

edge "pod_to_node" {
  title = "node"

  sql = <<-EOQ
    select
      n.uid as to_id,
      pod.uid as from_id
    from
      kubernetes_pod as pod,
      kubernetes_node as n
    where
      n.name = pod.node_name
      and pod.uid = any($1);
  EOQ

  param "pod_uids" {}
}
