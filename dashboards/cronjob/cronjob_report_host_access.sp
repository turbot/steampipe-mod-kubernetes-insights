dashboard "kubernetes_cronjob_host_access_report" {

  title         = "Kubernetes CronJob Host Access Report"
  documentation = file("./dashboards/cronjob/docs/cronjob_report_host_access.md")

  tags = merge(local.cronjob_common_tags, {
    type     = "Report"
    category = "Host Access"
  })

  container {

    card {
      query = query.kubernetes_cronjob_count
      width = 2
    }

    card {
      query = query.kubernetes_cronjob_container_host_network_count
      width = 2
    }

    card {
      query = query.kubernetes_cronjob_container_host_pid_count
      width = 2
    }

    card {
      query = query.kubernetes_cronjob_container_host_ipc_count
      width = 2
    }

  }

  table {
    column "UID" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.kubernetes_cronjob_detail.url_path}?input.cronjob_uid={{.UID | @uri}}"
    }

    query = query.kubernetes_cronjob_host_table
  }

}

query "kubernetes_cronjob_host_table" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      case when job_template -> 'spec' -> 'template' -> 'spec' ->> 'hostNetwork' = 'true'
      then 'Enabled' else 'Disabled' end as "Host Network",
      case when job_template -> 'spec' -> 'template' -> 'spec' ->> 'hostPID' = 'true'
      then 'Enabled' else 'Disabled' end as "Host PID",
      case when job_template -> 'spec' -> 'template' -> 'spec' ->> 'hostIPC' = 'true'
      then 'Enabled' else 'Disabled' end as "Host IPC",
      context_name as "Context Name"
    from
      kubernetes_cronjob
    order by
      name;
  EOQ
}
