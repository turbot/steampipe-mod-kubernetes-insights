dashboard "job_dashboard" {

  title         = "Kubernetes Job Dashboard"
  documentation = file("./dashboards/job/docs/job_dashboard.md")

  tags = merge(local.job_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.job_count
      width = 2
    }

    card {
      query = query.job_default_namespace_count
      width = 2
    }

    card {
      query = query.job_container_host_network_count
      width = 2
      href  = dashboard.job_host_access_report.url_path
    }

    card {
      query = query.job_container_host_pid_count
      width = 2
      href  = dashboard.job_host_access_report.url_path
    }

    card {
      query = query.job_container_host_ipc_count
      width = 2
      href  = dashboard.job_host_access_report.url_path
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Default Namespace Status"
      query = query.job_default_namespace_status
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
      title = "Host Network Access Status"
      query = query.job_container_host_network_status
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
      title = "Host PID Sharing Status"
      query = query.job_container_host_pid_status
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
      title = "Host IPC Sharing Status"
      query = query.job_container_host_ipc_status
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
      title = "Jobs by Cluster"
      query = query.job_by_context_name
      type  = "column"
      width = 4
    }

    chart {
      title = "Jobs by Namespace"
      query = query.job_by_namespace
      type  = "column"
      width = 4
    }

    chart {
      title = "Jobs by Age"
      query = query.job_by_creation_month
      type  = "column"
      width = 4
    }
  }

}

# Card Queries

query "job_count" {
  sql = <<-EOQ
    select
      count(*) as "Jobs"
    from
      kubernetes_job;
  EOQ
}

query "job_default_namespace_count" {
  sql = <<-EOQ
    select
      count(name) as value,
      'Default Namespace Used' as label,
      case count(name) when 0 then 'ok' else 'alert' end as type
    from
      kubernetes_job
    where
      namespace = 'default';
  EOQ
}

query "job_container_host_network_count" {
  sql = <<-EOQ
    select
      count(name) as value,
      'Host Network Access Enabled' as label,
      case count(name) when 0 then 'ok' else 'alert' end as type
    from
      kubernetes_job
    where
      template -> 'spec' ->> 'hostNetwork' = 'true';
  EOQ
}

query "job_container_host_pid_count" {
  sql = <<-EOQ
    select
      count(name) as value,
      'Host PID Sharing Enabled' as label,
      case count(name) when 0 then 'ok' else 'alert' end as type
    from
      kubernetes_job
    where
      template -> 'spec' ->> 'hostPID' = 'true';
  EOQ
}

query "job_container_host_ipc_count" {
  sql = <<-EOQ
    select
      count(name) as value,
      'Host IPC Sharing Enabled' as label,
      case count(name) when 0 then 'ok' else 'alert' end as type
    from
      kubernetes_job
    where
      template -> 'spec' ->> 'hostIPC' = 'true';
  EOQ
}

# Assessment Queries

query "job_default_namespace_status" {
  sql = <<-EOQ
    select
      case when namespace = 'default' then 'used' else 'unused' end as status,
      count(name)
    from
      kubernetes_job
    group by
      status;
  EOQ
}

query "job_container_host_network_status" {
  sql = <<-EOQ
    select
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'enabled' else 'disabled' end as status,
      count(*)
    from
      kubernetes_job
    group by
      status;
  EOQ
}

query "job_container_host_pid_status" {
  sql = <<-EOQ
    select
      case when template -> 'spec' ->> 'hostPID' = 'true' then 'enabled' else 'disabled' end as status,
      count(*)
    from
      kubernetes_job
    group by
      status;
  EOQ
}

query "job_container_host_ipc_status" {
  sql = <<-EOQ
    select
      case when template -> 'spec' ->> 'hostIPC' = 'true' then 'enabled' else 'disabled' end as status,
      count(*)
    from
      kubernetes_job
    group by
      status;
  EOQ
}

# Analysis Queries

query "job_by_namespace" {
  sql = <<-EOQ
    select
      namespace,
      count(name) as "jobs"
    from
      kubernetes_job
    group by
      namespace
    order by
      namespace;
  EOQ
}

query "job_by_context_name" {
  sql = <<-EOQ
    select
      context_name,
      count(name) as "jobs"
    from
      kubernetes_job
    group by
      context_name
    order by
      context_name;
  EOQ
}

query "job_by_creation_month" {
  sql = <<-EOQ
    with jobs as (
      select
        title,
        creation_timestamp,
        to_char(creation_timestamp,
          'YYYY-MM') as creation_month
      from
        kubernetes_job
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
                from jobs)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    jobs_by_month as (
      select
        creation_month,
        count(*)
      from
        jobs
      group by
        creation_month
    )
    select
      months.month,
      jobs_by_month.count
    from
      months
      left join jobs_by_month on months.month = jobs_by_month.creation_month
    order by
      months.month;
  EOQ
}
