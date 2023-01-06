locals {
  cronjob_common_tags = {
    service = "Kubernetes/CronJob"
  }
}

category "cronjob" {
  color = local.definition_color
  href  = "/kubernetes_insights.dashboard.kubernetes_cronjob_detail?input.cronjob_uid={{.properties.'UID' | @uri}}"
  icon  = "schedule"
  title = "CronJob"
}
