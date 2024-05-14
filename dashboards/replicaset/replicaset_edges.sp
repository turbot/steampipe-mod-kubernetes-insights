edge "replicaset_to_pod" {
  title = "pod"

  sql = <<-EOQ
     select
      pod_owner ->> 'uid' as from_id,
      p.uid as to_id
    from
      kubernetes_pod as p,
      join
      jsonb_array_elements(p.owner_references) as pod_owner as true
      join
      unnest($1::text[]) as u on context_name = split_part(u, '/', 2)
      and pod_owner ->> 'uid' = split_part(u, '/', 1);
  EOQ

  param "replicaset_uids" {}
}
