edge "deployment_to_replicaset" {
  title = "replicaset"

  sql = <<-EOQ
     select
      owner ->> 'uid' as from_id,
      coalesce(r.uid, concat(r.path, ':', r.start_line)) as to_id
    from
      kubernetes_replicaset as r,
      jsonb_array_elements(r.owner_references) as owner
    where
      owner ->> 'uid' = any($1);
  EOQ

  param "deployment_uids" {}
}
