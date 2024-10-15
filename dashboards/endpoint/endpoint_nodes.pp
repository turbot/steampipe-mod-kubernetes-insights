node "endpoint" {
  category = category.endpoint

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_endpoint
    where
      uid = any($1);
  EOQ

  param "endpoint_uids" {}
}
