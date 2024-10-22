edge "node_to_pod" {
  title = "pod"

  sql = <<-EOQ
    select
      n.uid as from_id,
      pod.uid as to_id
    from
      kubernetes_pod as pod,
      kubernetes_node as n
    where
      n.name = pod.node_name
      and n.context_name = pod.context_name
      and n.uid = any($1);
  EOQ

  param "node_uids" {}
}

edge "node_to_endpoint" {
  title = "endpoint"

  sql = <<-EOQ
     select
      n.uid as from_id,
      e.uid as to_id
    from
      kubernetes_node as n,
      kubernetes_endpoint as e,
      jsonb_array_elements(subsets) as s,
      jsonb_array_elements(s -> 'addresses') as a
    where
      n.name = a ->> 'nodeName'
      and n.context_name = e.context_name
      and n.uid = any($1);
  EOQ

  param "node_uids" {}
}

edge "node_to_volume" {
  title = "volume"

  sql = <<-EOQ
     select
      uid as from_id,
      v ->> 'name' as to_id
    from
      kubernetes_node,
      jsonb_array_elements(volumes_attached) as v
    where
      uid = any($1);
  EOQ

  param "node_uids" {}
}
