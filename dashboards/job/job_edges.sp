edge "job_to_pod" {
  title = "pod"

  sql = <<-EOQ
     select
      j.uid as from_id,
      pod.uid as to_id
    from
      kubernetes_job as j,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      j.uid = any($1)
      and pod_owner ->> 'uid' = j.uid;
  EOQ

  param "job_uids" {}
}
