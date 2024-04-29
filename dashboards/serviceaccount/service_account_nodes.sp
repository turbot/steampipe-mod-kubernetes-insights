node "service_account" {
  category = category.service_account

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Automount Service Account Token', automount_service_account_token,
        'Creation Timestamp', creation_timestamp,
        'Namespace', namespace,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_service_account
    join
      unnest($1::text[]) as u on context_name = split_part(u, '/', 2) and uid = split_part(u, '/', 1);
  EOQ

  param "service_account_uids" {}
}
