node "namespace" {
  category = category.namespace

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Phase', phase,
        'Creation Timestamp', creation_timestamp,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_namespace
    where
      uid = any($1);
  EOQ

  param "namespace_uids" {}
}
