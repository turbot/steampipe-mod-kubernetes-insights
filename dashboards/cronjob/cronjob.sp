locals {
  cronjob_common_tags = {
    service = "Kubernetes/CronJob"
  }
}

category "cronjob" {
  href  = "/kubernetes_insights.dashboard.kubernetes_cronjob_detail?input.cronjob_uid={{.properties.'UID' | @uri}}"
  //icon  = local.kubernetes_cronjob_icon
  icon  = "schedule"
  title = "CronJob"
}
