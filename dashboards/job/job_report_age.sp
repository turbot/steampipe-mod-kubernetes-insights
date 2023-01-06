dashboard "job_age_report" {

  title         = "Kubernetes Job Age Report"
  documentation = file("./dashboards/job/docs/job_report_age.md")

  tags = merge(local.job_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.job_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.job_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.job_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.job_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.job_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.job_1_year_count
    }
  }
  table {

    column "UID" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.job_detail.url_path}?input.job_uid={{.UID | @uri}}"
    }

    query = query.job_age_table
  }
}

query "job_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      kubernetes_job
    where
      creation_timestamp > now() - '1 days' :: interval;
  EOQ
}

query "job_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      kubernetes_job
    where
      creation_timestamp between symmetric now() - '1 days' :: interval
      and now() - '30 days' :: interval;
  EOQ
}

query "job_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      kubernetes_job
    where
      creation_timestamp between symmetric now() - '30 days' :: interval
      and now() - '90 days' :: interval;
  EOQ
}

query "job_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      kubernetes_job
    where
      creation_timestamp between symmetric (now() - '90 days'::interval)
      and (now() - '365 days'::interval);
  EOQ
}

query "job_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      kubernetes_job
    where
      creation_timestamp <= now() - '1 year' :: interval;
  EOQ
}

query "job_age_table" {
  sql = <<-EOQ
    select
      name as "Name",
      now()::date - creation_timestamp::date as "Age in Days",
      creation_timestamp as "Create Time",
      context_name as "Context Name",
      uid as "UID"
    from
      kubernetes_job
    order by
      name;
  EOQ
}
