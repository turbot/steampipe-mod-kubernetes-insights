node "daemonset" {
  category = category.daemonset

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Min Ready Seconds', min_ready_seconds,
        'Revision History Limit', revision_history_limit,
        'Creation Timestamp', creation_timestamp,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_daemonset
    where
      uid = any($1);
  EOQ

  param "daemonset_uids" {}
}
