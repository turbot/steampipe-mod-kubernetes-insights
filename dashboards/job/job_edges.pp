edge "job_to_node" {
  title = "node"

  sql = <<-EOQ
     select
      pod_owner ->> 'uid' as from_id,
      n.uid as to_id
    from
      kubernetes_pod as p
      cross join jsonb_array_elements(p.owner_references) as pod_owner
      left join kubernetes_node as n
      on n.name = p.node_name
      and n.context_name = p.context_name
    where
      p.node_name <> ''
      and pod_owner ->> 'uid' = any($1);
  EOQ

  param "job_uids" {}
}

edge "job_to_pod" {
  title = "pod"

  sql = <<-EOQ
     select
      pod_owner ->> 'uid' as from_id,
      p.uid as to_id
    from
      kubernetes_pod as p,
      jsonb_array_elements(p.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = any($1);
  EOQ

  param "job_uids" {}
}
