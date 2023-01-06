node "service" {
  category = category.service

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Type', type,
        'Cluster IP', cluster_ip,
        'Creation Timestamp', creation_timestamp,
        'Namespace', namespace,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_service
    where
      uid = any($1);
  EOQ

  param "service_uids" {}
}
