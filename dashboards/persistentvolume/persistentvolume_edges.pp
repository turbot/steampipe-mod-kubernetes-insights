edge "persistent_volume_claim_to_persistent_volume" {
  title = "persistent volume"

  sql = <<-EOQ
     select
      c.uid as from_id,
      pv.uid as to_id
    from
      kubernetes_persistent_volume as pv
      join kubernetes_persistent_volume_claim as c
      on pv.name = c.volume_name
      and pv.context_name = c.context_name
    where
      c.uid = any($1);
  EOQ

  param "persistent_volume_claim_uids" {}
}
