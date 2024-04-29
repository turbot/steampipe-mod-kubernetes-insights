node "statefulset" {
  category = category.statefulset

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Service Name', service_name,
        'Replicas', replicas,
        'Creation Timestamp', creation_timestamp,
        'Namespace', namespace,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_stateful_set
    join
      unnest($1::text[]) as u on context_name = split_part(u, '/', 2) and uid = split_part(u, '/', 1);
  EOQ

  param "statefulset_uids" {}
}
