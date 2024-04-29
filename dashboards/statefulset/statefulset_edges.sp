edge "statefulset_to_pod" {
  title = "pod"

  sql = <<-EOQ
     select
      pod_owner ->> 'uid' as from_id,
      p.uid as to_id
    from
      kubernetes_pod as p,
    cross join lateral
      jsonb_array_elements(p.owner_references) as pod_owner
    join
      unnest($1::text[]) as u on pod_owner ->> 'uid' = split_part(u, '/', 1)
      and context_name = split_part(u, '/', 2);
  EOQ

  param "statefulset_uids" {}
}
