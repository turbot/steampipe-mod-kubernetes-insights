node "configmap" {
  category = category.configmap

  sql = <<-EOQ
    select
      uid as id,
      name as title,
      jsonb_build_object(
        'UID', uid,
        'Immutable', immutable,
        'Creation Timestamp', creation_timestamp,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_config_map
    where
      uid = any($1);
  EOQ

  param "configmap_uids" {}
}
