dashboard "kubernetes_deployment_host_access_report" {

  title         = "Kubernetes Deployment Host Access Report"
  documentation = file("./dashboards/deployment/docs/deployment_report_host_access.md")

  tags = merge(local.deployment_common_tags, {
    type     = "Report"
    category = "Host Access"
  })

  container {

    card {
      query = query.kubernetes_deployment_count
      width = 2
    }

    card {
      query = query.kubernetes_deployment_container_host_network_count
      width = 2
    }

    card {
      query = query.kubernetes_deployment_container_host_pid_count
      width = 2
    }

    card {
      query = query.kubernetes_deployment_container_host_ipc_count
      width = 2
    }

  }

  table {
    column "UID" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.kubernetes_deployment_detail.url_path}?input.deployment_uid={{.UID | @uri}}"
    }

    query = query.kubernetes_deployment_host_table
  }

}

query "kubernetes_deployment_host_table" {
  sql = <<-EOQ
    select
      name as "Name",
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'Enabled' else 'Disabled' end as "Host Network",
      case when template -> 'spec' ->> 'hostPID' = 'true' then 'Enabled' else 'Disabled' end as "Host PID",
      case when template -> 'spec' ->> 'hostIPC' = 'true' then 'Enabled' else 'Disabled' end as "Host IPC",
      context_name as "Context Name",
      uid as "UID"
    from
      kubernetes_deployment
    order by
      name;
  EOQ
}
