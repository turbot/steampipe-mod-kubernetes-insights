dashboard "cronjob_host_access_report" {

  title         = "Kubernetes CronJob Host Access Report"
  documentation = file("./dashboards/cronjob/docs/cronjob_report_host_access.md")

  tags = merge(local.cronjob_common_tags, {
    type     = "Report"
    category = "Host Access"
  })

  container {

    card {
      query = query.cronjob_count
      width = 3
    }

    card {
      query = query.cronjob_container_host_network_count
      width = 3
    }

    card {
      query = query.cronjob_container_host_pid_count
      width = 3
    }

    card {
      query = query.cronjob_container_host_ipc_count
      width = 3
    }

  }

  table {
    column "UID" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.cronjob_detail.url_path}?input.cronjob_uid={{.UID | @uri}}"
    }

    query = query.cronjob_host_table
  }

}

query "cronjob_host_table" {
  sql = <<-EOQ
    select
      name as "Name",
      case when job_template -> 'spec' -> 'template' -> 'spec' ->> 'hostNetwork' = 'true'
      then 'Enabled' else 'Disabled' end as "Host Network",
      case when job_template -> 'spec' -> 'template' -> 'spec' ->> 'hostPID' = 'true'
      then 'Enabled' else 'Disabled' end as "Host PID",
      case when job_template -> 'spec' -> 'template' -> 'spec' ->> 'hostIPC' = 'true'
      then 'Enabled' else 'Disabled' end as "Host IPC",
      context_name as "Context Name",
      uid as "UID"
    from
      kubernetes_cronjob
    order by
      name;
  EOQ
}
