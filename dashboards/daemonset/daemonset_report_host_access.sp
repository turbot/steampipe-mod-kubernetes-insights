dashboard "kubernetes_daemonset_host_access_report" {

  title         = "Kubernetes DaemonSet Host Access Report"
  documentation = file("./dashboards/daemonset/docs/daemonset_report_host_access.md")

  tags = merge(local.daemonset_common_tags, {
    type     = "Report"
    category = "Host Access"
  })

  container {

    card {
      query = query.kubernetes_daemonset_count
      width = 2
    }

    card {
      query = query.kubernetes_daemonset_container_host_network_count
      width = 2
    }

    card {
      query = query.kubernetes_daemonset_container_host_pid_count
      width = 2
    }

    card {
      query = query.kubernetes_daemonset_container_host_ipc_count
      width = 2
    }

  }

  table {
    column "UID" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.kubernetes_daemonset_detail.url_path}?input.daemonset_uid={{.UID | @uri}}"
    }

    query = query.kubernetes_daemonset_host_table
  }

}

query "kubernetes_daemonset_host_table" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      template -> 'spec' ->> 'hostNetwork' as "Host Network",
      template -> 'spec' ->> 'hostPID' as "Host PID",
      template -> 'spec' ->> 'hostIPC' as "Host IPC",
      context_name as "Context Name"
    from
      kubernetes_daemonset
    order by
      name;
  EOQ
}
