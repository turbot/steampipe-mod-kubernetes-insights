dashboard "kubernetes_deployment_age_report" {

  title         = "Kubernetes Deployment Age Report"
  documentation = file("./dashboards/deployment/docs/deployment_report_age.md")

  tags = merge(local.deployment_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.kubernetes_deployment_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.kubernetes_deployment_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.kubernetes_deployment_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.kubernetes_deployment_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.kubernetes_deployment_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.kubernetes_deployment_1_year_count
    }
  }
  # table {

  #   column "UID" {
  #     display = "none"
  #   }

  #   column "Name" {
  #     href = "${dashboard.kubernetes_deployment_detail.url_path}?input.deployment_uid={{.UID | @uri}}"
  #   }

  #   query = query.kubernetes_deployment_age_table
  # }
}

query "kubernetes_deployment_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      kubernetes_deployment
    where
      creation_timestamp > now() - '1 days' :: interval;
  EOQ
}

query "kubernetes_deployment_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      kubernetes_deployment
    where
      creation_timestamp between symmetric now() - '1 days' :: interval
      and now() - '30 days' :: interval;
  EOQ
}

query "kubernetes_deployment_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      kubernetes_deployment
    where
      creation_timestamp between symmetric now() - '30 days' :: interval
      and now() - '90 days' :: interval;
  EOQ
}

query "kubernetes_deployment_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      kubernetes_deployment
    where
      creation_timestamp between symmetric (now() - '90 days'::interval)
      and (now() - '365 days'::interval);
  EOQ
}

query "kubernetes_deployment_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      kubernetes_deployment
    where
      creation_timestamp <= now() - '1 year' :: interval;
  EOQ
}

query "kubernetes_deployment_age_table" {
  query = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      now()::date - creation_timestamp::date as "Age in Days",
      creation_timestamp as "Create Time",
      context_name as "Context Name"
    from
      kubernetes_deployment
    order by
      name;
  EOQ
}
