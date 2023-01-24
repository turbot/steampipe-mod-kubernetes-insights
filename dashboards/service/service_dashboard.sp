dashboard "service_dashboard" {

  title         = "Kubernetes Service Dashboard"
  documentation = file("./dashboards/service/docs/service_dashboard.md")

  tags = merge(local.service_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.service_count
      width = 3
    }

    card {
      query = query.service_default_namespace_count
      width = 3
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Default Namespace Status"
      query = query.service_default_namespace_status
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

  }

  container {

    title = "Analysis"

    chart {
      title = "Services by Cluster"
      query = query.service_by_context_name
      type  = "column"
      width = 4
    }

    chart {
      title = "Services by Namespace"
      query = query.service_by_namespace
      type  = "column"
      width = 4
    }

    chart {
      title = "Services by Age"
      query = query.service_by_creation_month
      type  = "column"
      width = 4
    }
  }

}

# Card Queries

query "service_count" {
  sql = <<-EOQ
    select
      count(*) as "Services"
    from
      kubernetes_service;
  EOQ
}

query "service_default_namespace_count" {
  sql = <<-EOQ
    select
      count(name) as value,
      'Default Namespace Used' as label,
      case count(name) when 0 then 'ok' else 'alert' end as type
    from
      kubernetes_service
    where
      namespace = 'default';
  EOQ
}

# Assessment Queries

query "service_default_namespace_status" {
  sql = <<-EOQ
    select
      case when namespace = 'default' then 'used' else 'unused' end as status,
      count(name)
    from
      kubernetes_service
    group by
      status;
  EOQ
}

# Analysis Queries

query "service_by_namespace" {
  sql = <<-EOQ
    select
      namespace,
      count(name) as "services"
    from
      kubernetes_service
    group by
      namespace
    order by
      namespace;
  EOQ
}

query "service_by_context_name" {
  sql = <<-EOQ
    select
      context_name,
      count(name) as "services"
    from
      kubernetes_service
    group by
      context_name
    order by
      context_name;
  EOQ
}

query "service_by_creation_month" {
  sql = <<-EOQ
    with services as (
      select
        title,
        creation_timestamp,
        to_char(creation_timestamp,
          'YYYY-MM') as creation_month
      from
        kubernetes_service
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
                from services)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    service_by_month as (
      select
        creation_month,
        count(*)
      from
        services
      group by
        creation_month
    )
    select
      months.month,
      service_by_month.count
    from
      months
      left join service_by_month on months.month = service_by_month.creation_month
    order by
      months.month;
  EOQ
}
