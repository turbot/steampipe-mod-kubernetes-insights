node "pod" {
  category = category.pod

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Restart Policy', restart_policy,
        'Service Account Name', service_account_name,
        'Phase', phase,
        'Namespace', namespace,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_pod
    where
      uid = any($1);
  EOQ

  param "pod_uids" {}
}
