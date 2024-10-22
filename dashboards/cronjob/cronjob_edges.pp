edge "cronjob_to_job" {
  title = "job"

  sql = <<-EOQ
     select
      owner ->> 'uid' as from_id,
      j.uid as to_id
    from
      kubernetes_job as j,
      jsonb_array_elements(j.owner_references) as owner
    where
      owner ->> 'uid' = any($1);
  EOQ

  param "cronjob_uids" {}
}
