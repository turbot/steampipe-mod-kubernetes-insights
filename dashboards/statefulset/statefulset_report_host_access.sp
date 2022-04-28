dashboard "kubernetes_statefulset_host_access_report" {

  title         = "Kubernetes StatefulSet Host Access Report"
  documentation = file("./dashboards/statefulset/docs/statefulset_report_host_access.md")

  tags = merge(local.statefulset_common_tags, {
    type     = "Report"
    category = "Host Access"
  })

  container {

    card {
      query = query.kubernetes_statefulset_count
      width = 2
    }

    card {
      query = query.kubernetes_statefulset_container_host_network_count
      width = 2
    }

    card {
      query = query.kubernetes_statefulset_container_host_pid_count
      width = 2
    }

    card {
      query = query.kubernetes_statefulset_container_host_ipc_count
      width = 2
    }

  }

  table {
    column "UID" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.kubernetes_statefulset_detail.url_path}?input.statefulset_uid={{.UID | @uri}}"
    }

    query = query.kubernetes_statefulset_host_table
  }

}

query "kubernetes_statefulset_host_table" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      template -> 'spec' ->> 'hostNetwork' as "Host Network",
      template -> 'spec' ->> 'hostPID' as "Host PID",
      template -> 'spec' ->> 'hostIPC' as "Host IPC",
      context_name as "Context Name"
    from
      kubernetes_statefulset
    order by
      name;
  EOQ
}
