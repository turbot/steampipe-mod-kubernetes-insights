node "replicaset" {
  category = category.replicaset

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Replicas', replicas,
        'Creation Timestamp', creation_timestamp,
        'Namespace', namespace,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_replicaset
    where
      uid = any($1);
  EOQ

  param "replicaset_uids" {}
}
