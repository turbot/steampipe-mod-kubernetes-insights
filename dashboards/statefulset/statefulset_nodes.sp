node "statefulset" {
  category = category.statefulset

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Namespace', namespace,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_stateful_set
    where
      uid = any($1);
  EOQ

  param "statefulset_uids" {}
}
