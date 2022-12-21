locals {
  job_common_tags = {
    service = "Kubernetes/Job"
  }
}

category "job" {
  href  = "/kubernetes_insights.dashboard.kubernetes_job_detail?input.job_uid={{.properties.'UID' | @uri}}"
  icon  = local.kubernetes_job_icon
  title = "Job"
}
