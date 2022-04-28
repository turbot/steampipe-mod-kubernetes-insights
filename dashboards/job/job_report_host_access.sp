dashboard "kubernetes_job_host_access_report" {

  title         = "Kubernetes Job Host Access Report"
  documentation = file("./dashboards/job/docs/job_report_host_access.md")

  tags = merge(local.job_common_tags, {
    type     = "Report"
    category = "Host Access"
  })

  container {

    card {
      query = query.kubernetes_job_count
      width = 2
    }

    card {
      query = query.kubernetes_job_container_host_network_count
      width = 2
    }

    card {
      query = query.kubernetes_job_container_host_pid_count
      width = 2
    }

    card {
      query = query.kubernetes_job_container_host_ipc_count
      width = 2
    }

  }

  table {
    column "UID" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.kubernetes_job_detail.url_path}?input.job_uid={{.UID | @uri}}"
    }

    query = query.kubernetes_job_host_table
  }

}

query "kubernetes_job_host_table" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      template -> 'spec' ->> 'hostNetwork' as "Host Network",
      template -> 'spec' ->> 'hostPID' as "Host PID",
      template -> 'spec' ->> 'hostIPC' as "Host IPC",
      context_name as "Context Name"
    from
      kubernetes_job
    order by
      name;
  EOQ
}
