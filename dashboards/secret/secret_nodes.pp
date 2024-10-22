node "secret" {
  category = category.secret

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Immutable', immutable,
        'Creation Timestamp', creation_timestamp,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_secret
    where
      uid = any($1);
  EOQ

  param "secret_uids" {}
}


