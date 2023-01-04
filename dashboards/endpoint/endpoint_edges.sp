edge "endpoint_to_node" {
  title = "node"

  sql = <<-EOQ
     select
      n.uid as to_id,
      e.uid as from_id
    from
      kubernetes_node as n,
      kubernetes_endpoint as e,
      jsonb_array_elements(subsets) as s,
      jsonb_array_elements(s -> 'addresses') as a
    where
      n.name = a ->> 'nodeName'
      and e.uid = any($1);
  EOQ

  param "endpoint_uids" {}
}
