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
      and n.uid = any($1);
  EOQ

  param "node_uids" {}
}
