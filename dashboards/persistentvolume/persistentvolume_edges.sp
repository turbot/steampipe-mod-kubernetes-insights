edge "pod_to_persistent_volume" {
  title = "persistent volume"

  sql = <<-EOQ
     select
      p.uid as from_id,
      pv.uid as to_id
    from
      kubernetes_pod as p,
      jsonb_array_elements(volumes) as v
      left join kubernetes_persistent_volume as pv
      on v -> 'persistentVolumeClaim' ->> 'claimName' = pv.claim_ref ->> 'name'
    where
      p.uid = any($1);
  EOQ

  param "pod_uids" {}
}
