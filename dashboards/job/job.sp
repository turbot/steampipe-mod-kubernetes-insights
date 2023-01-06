locals {
  job_common_tags = {
    service = "Kubernetes/Job"
  }
}

category "job" {
  title = "Job"
  color = local.definition_color
  href  = "/kubernetes_insights.dashboard.job_detail?input.job_uid={{.properties.'UID' | @uri}}"
  icon  = "task_alt"
}
