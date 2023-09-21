node "deployment" {
  category = category.deployment

  sql = <<-EOQ
    select
      coalesce(uid, concat(path, ':', start_line)) as id,
      title as title,
      jsonb_build_object(
        'UID', coalesce(uid, concat(path, ':', start_line)),
        'Replicas', replicas,
        'Paused', paused,
        'Namespace', namespace,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_deployment
    where
      coalesce(uid, concat(path, ':', start_line)) = any($1);
  EOQ

  param "deployment_uids" {}
}
