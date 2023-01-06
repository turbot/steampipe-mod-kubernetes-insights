locals {
  cronjob_common_tags = {
    service = "Kubernetes/CronJob"
  }
}

category "cronjob" {
  title = "CronJob"
  color = local.definition_color
  href  = "/kubernetes_insights.dashboard.cronjob_detail?input.cronjob_uid={{.properties.'UID' | @uri}}"
  icon  = "schedule"
}
