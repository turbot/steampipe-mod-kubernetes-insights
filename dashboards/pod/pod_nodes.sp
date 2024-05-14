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
      join
      unnest($1::text[]) as u on context_name = split_part(u, '/', 2)
      and uid = split_part(u, '/', 1);
  EOQ

  param "pod_uids" {}
}
