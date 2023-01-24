dashboard "deployment_dashboard" {

  title         = "Kubernetes Deployment Dashboard"
  documentation = file("./dashboards/deployment/docs/deployment_dashboard.md")

  tags = merge(local.deployment_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.deployment_count
      width = 2
    }

    card {
      query = query.deployment_default_namespace_count
      width = 2
    }

    card {
      query = query.deployment_replica_count
      width = 2
      href  = dashboard.deployment_ha_report.url_path
    }

    card {
      query = query.deployment_container_host_network_count
      width = 2
      href  = dashboard.deployment_host_access_report.url_path
    }

    card {
      query = query.deployment_container_host_pid_count
      width = 2
      href  = dashboard.deployment_host_access_report.url_path
    }

    card {
      query = query.deployment_container_host_ipc_count
      width = 2
      href  = dashboard.deployment_host_access_report.url_path
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Default Namespace Status"
      query = query.deployment_default_namespace_status
      type  = "donut"
      width = 4

      series "count" {
        point "used" {
          color = "alert"
        }
        point "unused" {
          color = "ok"
        }
      }
    }

    chart {
      title = "Replicas HA Status"
      query = query.deployment_container_replica_status
      type  = "donut"
      width = 4

      series "count" {
        point "HA" {
          color = "ok"
        }
        point "non-HA" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Host Network Access Status"
      query = query.deployment_container_host_network_status
      type  = "donut"
      width = 4

      series "count" {
        point "enabled" {
          color = "alert"
        }
        point "disabled" {
          color = "ok"
        }
      }
    }

    chart {
      title = "Host PID Sharing Status"
      query = query.deployment_container_host_pid_status
      type  = "donut"
      width = 4

      series "count" {
        point "enabled" {
          color = "alert"
        }
        point "disabled" {
          color = "ok"
        }
      }
    }

    chart {
      title = "Host IPC Sharing Status"
      query = query.deployment_container_host_ipc_status
      type  = "donut"
      width = 4

      series "count" {
        point "enabled" {
          color = "alert"
        }
        point "disabled" {
          color = "ok"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Deployments by Cluster"
      query = query.deployment_by_context_name
      type  = "column"
      width = 4
    }

    chart {
      title = "Deployments by Namespace"
      query = query.deployment_by_namespace
      type  = "column"
      width = 4
    }

    chart {
      title = "Deployments by Age"
      query = query.deployment_by_creation_month
      type  = "column"
      width = 4
    }
  }

}

# Card Queries

query "deployment_count" {
  sql = <<-EOQ
    select
      count(*) as "Deployments"
    from
      kubernetes_deployment;
  EOQ
}

query "deployment_default_namespace_count" {
  sql = <<-EOQ
    select
      count(name) as value,
      'Default Namespace Used' as label,
      case count(name) when 0 then 'ok' else 'alert' end as type
    from
      kubernetes_deployment
    where
      namespace = 'default';
  EOQ
}

query "deployment_replica_count" {
  sql = <<-EOQ
    select
      count(name) as value,
      'Replicas Without HA (<3)' as label,
      case count(name) when 0 then 'ok' else 'alert' end as type
    from
      kubernetes_deployment
    where
      replicas < 3;
  EOQ
}

query "deployment_container_host_network_count" {
  sql = <<-EOQ
    select
      count(name) as value,
      'Host Network Access Enabled' as label,
      case count(name) when 0 then 'ok' else 'alert' end as type
    from
      kubernetes_deployment
    where
      template -> 'spec' ->> 'hostNetwork' = 'true';
  EOQ
}

query "deployment_container_host_pid_count" {
  sql = <<-EOQ
    select
      count(name) as value,
      'Host PID Sharing Enabled' as label,
      case count(name) when 0 then 'ok' else 'alert' end as type
    from
      kubernetes_deployment
    where
      template -> 'spec' ->> 'hostPID' = 'true';
  EOQ
}

query "deployment_container_host_ipc_count" {
  sql = <<-EOQ
    select
      count(name) as value,
      'Host IPC Sharing Enabled' as label,
      case count(name) when 0 then 'ok' else 'alert' end as type
    from
      kubernetes_deployment
    where
      template -> 'spec' ->> 'hostIPC' = 'true';
  EOQ
}

# Assessment Queries

query "deployment_default_namespace_status" {
  sql = <<-EOQ
    select
      case when namespace = 'default' then 'used' else 'unused' end as status,
      count(name)
    from
      kubernetes_deployment
    group by
      status;
  EOQ
}

query "deployment_container_host_network_status" {
  sql = <<-EOQ
    select
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'enabled' else 'disabled' end as status,
      count(*)
    from
      kubernetes_deployment
    group by
      status;
  EOQ
}

query "deployment_container_host_pid_status" {
  sql = <<-EOQ
    select
      case when template -> 'spec' ->> 'hostPID' = 'true' then 'enabled' else 'disabled' end as status,
      count(*)
    from
      kubernetes_deployment
    group by
      status;
  EOQ
}

query "deployment_container_host_ipc_status" {
  sql = <<-EOQ
    select
      case when template -> 'spec' ->> 'hostIPC' = 'true' then 'enabled' else 'disabled' end as status,
      count(*)
    from
      kubernetes_deployment
    group by
      status;
  EOQ
}

query "deployment_container_replica_status" {
  sql = <<-EOQ
    select
      case when replicas < '3' then 'non-HA' else 'HA' end as status,
      count(name)
    from
      kubernetes_deployment
    group by
      status;
  EOQ
}

# Analysis Queries

query "deployment_by_namespace" {
  sql = <<-EOQ
    select
      namespace,
      count(name) as "deployments"
    from
      kubernetes_deployment
    group by
      namespace
    order by
      namespace;
  EOQ
}

query "deployment_by_context_name" {
  sql = <<-EOQ
    select
      context_name,
      count(name) as "deployments"
    from
      kubernetes_deployment
    group by
      context_name
    order by
      context_name;
  EOQ
}

query "deployment_by_creation_month" {
  sql = <<-EOQ
    with deployments as (
      select
        title,
        creation_timestamp,
        to_char(creation_timestamp,
          'YYYY-MM') as creation_month
      from
        kubernetes_deployment
    ),
    months as (
      select
        to_char(d,
          'YYYY-MM') as month
      from
        generate_series(date_trunc('month',
            (
              select
                min(creation_timestamp)
                from deployments)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    deployments_by_month as (
      select
        creation_month,
        count(*)
      from
        deployments
      group by
        creation_month
    )
    select
      months.month,
      deployments_by_month.count
    from
      months
      left join deployments_by_month on months.month = deployments_by_month.creation_month
    order by
      months.month;
  EOQ
}
