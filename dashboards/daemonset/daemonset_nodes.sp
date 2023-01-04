node "daemonset" {
  category = category.daemonset

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_daemonset
    where
      uid = any($1);
  EOQ

  param "daemonset_uids" {}
}
