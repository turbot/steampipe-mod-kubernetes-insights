node "deployment" {
  category = category.deployment

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Replicas', replicas,
        'Paused', paused,
        'Namespace', namespace,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_deployment
    where
      uid = any($1);
  EOQ

  param "deployment_uids" {}
}
