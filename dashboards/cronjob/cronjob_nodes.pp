node "cronjob" {
  category = category.cronjob

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Schedule', schedule,
        'Suspend', suspend,
        'Last Schedule Time', last_schedule_time,
        'Namespace', namespace,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_cronjob
    where
      uid = any($1);
  EOQ

  param "cronjob_uids" {}
}
