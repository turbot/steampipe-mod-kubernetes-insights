edge "replicaset_to_pod" {
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

  param "replicaset_uids" {}
}
