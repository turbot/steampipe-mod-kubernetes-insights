node "persistent_volume" {
  category = category.persistent_volume

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Phase', phase,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_persistent_volume
    where
      uid = any($1);
  EOQ

  param "persistent_volume_uids" {}
}
