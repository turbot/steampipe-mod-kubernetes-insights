node "job" {
  category = category.job

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Parallelism', parallelism,
        'Completions', completions,
        'Backoff Limit', backoff_limit,
        'Start Time', start_time,
        'Completion Time', completion_time,
        'Namespace', namespace,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_job
    where
      uid = any($1);
  EOQ

  param "job_uids" {}
}
