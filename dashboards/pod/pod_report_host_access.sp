dashboard "kubernetes_pod_host_access_report" {

  title         = "Kubernetes Pod Host Access Report"
  documentation = file("./dashboards/pod/docs/pod_report_host_access.md")

  tags = merge(local.pod_common_tags, {
    type     = "Report"
    category = "Host Access"
  })

  container {

    card {
      query = query.kubernetes_pod_count
      width = 2
    }

    card {
      query = query.kubernetes_pod_container_host_network_count
      width = 2
    }

    card {
      query = query.kubernetes_pod_container_host_pid_count
      width = 2
    }

    card {
      query = query.kubernetes_pod_container_host_ipc_count
      width = 2
    }

  }

  table {
    column "UID" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.kubernetes_pod_detail.url_path}?input.pod_uid={{.UID | @uri}}"
    }

    query = query.kubernetes_pod_host_table
  }

}

query "kubernetes_pod_host_table" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      host_network as "Host Network",
      host_pid as "Host PID",
      host_ipc as "Host IPC",
      context_name as "Context Name"
    from
      kubernetes_pod
    order by
      name;
  EOQ
}
