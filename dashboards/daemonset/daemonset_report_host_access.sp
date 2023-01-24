dashboard "daemonset_host_access_report" {

  title         = "Kubernetes DaemonSet Host Access Report"
  documentation = file("./dashboards/daemonset/docs/daemonset_report_host_access.md")

  tags = merge(local.daemonset_common_tags, {
    type     = "Report"
    category = "Host Access"
  })

  container {

    card {
      query = query.daemonset_count
      width = 3
    }

    card {
      query = query.daemonset_container_host_network_count
      width = 3
    }

    card {
      query = query.daemonset_container_host_pid_count
      width = 3
    }

    card {
      query = query.daemonset_container_host_ipc_count
      width = 3
    }

  }

  table {
    column "UID" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.daemonset_detail.url_path}?input.daemonset_uid={{.UID | @uri}}"
    }

    query = query.daemonset_host_table
  }

}

query "daemonset_host_table" {
  sql = <<-EOQ
    select
      name as "Name",
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'Enabled' else 'Disabled' end as "Host Network",
      case when template -> 'spec' ->> 'hostPID' = 'true' then 'Enabled' else 'Disabled' end as "Host PID",
      case when template -> 'spec' ->> 'hostIPC' = 'true' then 'Enabled' else 'Disabled' end as "Host IPC",
      context_name as "Context Name",
      uid as "UID"
    from
      kubernetes_daemonset
    order by
      name;
  EOQ
}
