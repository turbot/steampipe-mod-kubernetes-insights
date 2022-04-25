dashboard "kubernetes_deployment_dashboard" {

  title         = "kubernetes Deployment Dashboard"
  documentation = file("./dashboards/deployment/docs/deployment_dashboard.md")

  tags = merge(local.deployment_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.kubernetes_deployment_count
      width = 2
    }

    card {
      query = query.kubernetes_deployment_default_namespace_count
      width = 2
    }

    card {
      query = query.kubernetes_deployment_replica_count
      width = 2
      href  = dashboard.kubernetes_deployment_replicas_report.url_path
    }

    card {
      query = query.kubernetes_deployment_container_host_network_count
      width = 2
    }

    card {
      query = query.kubernetes_deployment_container_host_process_count
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Default Namespace Status"
      query = query.kubernetes_deployment_default_namespace_status
      type  = "donut"
      width = 3

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
      title = "Replicas Status"
      query = query.kubernetes_deployment_container_replica_status
      type  = "donut"
      width = 3

      series "count" {
        point ">= 3" {
          color = "ok"
        }
        point "< 3" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Host Network Access Status"
      query = query.kubernetes_deployment_container_host_network_status
      type  = "donut"
      width = 3

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
      title = "Host Process Sharing Status"
      query = query.kubernetes_deployment_container_host_process_status
      type  = "donut"
      width = 3

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
      query = query.kubernetes_deployment_by_context_name
      type  = "column"
      width = 4
    }

    chart {
      title = "Deployments by Namespace"
      query = query.kubernetes_deployment_by_namespace
      type  = "column"
      width = 4
    }

    chart {
      title = "Deployments by Age"
      query = query.kubernetes_deployment_by_creation_month
      type  = "column"
      width = 4
    }
  }

}

# Card Queries

query "kubernetes_deployment_count" {
  sql = <<-EOQ
    select
      count(*) as "Deployments"
    from
      kubernetes_deployment;
  EOQ
}

query "kubernetes_deployment_default_namespace_count" {
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

query "kubernetes_deployment_replica_count" {
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

query "kubernetes_deployment_container_host_network_count" {
  sql = <<-EOQ
    select
      count(name) as value,
      'Host Network Access' as label,
      case count(name) when 0 then 'ok' else 'alert' end as type
    from
      kubernetes_deployment
    where
      template -> 'spec' ->> 'hostNetwork' = 'true';
  EOQ
}

query "kubernetes_deployment_container_host_process_count" {
  sql = <<-EOQ
    select
      count(name) as value,
      'Host Process Sharing Enabled' as label,
      case count(name) when 0 then 'ok' else 'alert' end as type
    from
      kubernetes_deployment
    where
      template -> 'spec' ->> 'hostPID' = 'true' or template -> 'spec' ->> 'hostIPC' = 'true';
  EOQ
}

# Assessment Queries

query "kubernetes_deployment_default_namespace_status" {
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

query "kubernetes_deployment_container_host_network_status" {
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

query "kubernetes_deployment_container_host_process_status" {
  sql = <<-EOQ
    select
      case when template -> 'spec' ->> 'hostPID' = 'true' or template -> 'spec' ->> 'hostIPC' = 'true'
        then 'enabled' else 'disabled' end as status,
      count(*)
    from
      kubernetes_deployment
    group by
      status;
  EOQ
}

query "kubernetes_deployment_container_replica_status" {
  sql = <<-EOQ
    select
      case when replicas < '3' then '< 3' else '>= 3' end as status,
      count(name)
    from
      kubernetes_deployment
    group by
      status;
  EOQ
}

# Analysis Queries

query "kubernetes_deployment_by_namespace" {
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

query "kubernetes_deployment_by_context_name" {
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

query "kubernetes_deployment_by_creation_month" {
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
