locals {
  job_common_tags = {
    service = "Kubernetes/Job"
  }
}

category "job" {
  color = local.definition_color
  href  = "/kubernetes_insights.dashboard.kubernetes_job_detail?input.job_uid={{.properties.'UID' | @uri}}"
  icon  = "task_alt"
  title = "Job"
}
