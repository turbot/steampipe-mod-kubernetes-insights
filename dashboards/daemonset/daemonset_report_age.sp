dashboard "daemonset_age_report" {

  title         = "Kubernetes DaemonSet Age Report"
  documentation = file("./dashboards/daemonset/docs/daemonset_report_age.md")

  tags = merge(local.daemonset_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.daemonset_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.daemonset_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.daemonset_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.daemonset_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.daemonset_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.daemonset_1_year_count
    }
  }

  table {
    column "UID" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.daemonset_detail.url_path}?input.daemonset_uid={{.UID | @uri}}"
    }

    query = query.daemonset_age_table
  }
}

query "daemonset_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      kubernetes_daemonset
    where
      creation_timestamp > now() - '1 days' :: interval;
  EOQ
}

query "daemonset_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      kubernetes_daemonset
    where
      creation_timestamp between symmetric now() - '1 days' :: interval
      and now() - '30 days' :: interval;
  EOQ
}

query "daemonset_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      kubernetes_daemonset
    where
      creation_timestamp between symmetric now() - '30 days' :: interval
      and now() - '90 days' :: interval;
  EOQ
}

query "daemonset_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      kubernetes_daemonset
    where
      creation_timestamp between symmetric (now() - '90 days'::interval)
      and (now() - '365 days'::interval);
  EOQ
}

query "daemonset_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      kubernetes_daemonset
    where
      creation_timestamp <= now() - '1 year' :: interval;
  EOQ
}

query "daemonset_age_table" {
  sql = <<-EOQ
    select
      name as "Name",
      now()::date - creation_timestamp::date as "Age in Days",
      creation_timestamp as "Create Time",
      context_name as "Context Name",
      uid as "UID"
    from
      kubernetes_daemonset
    order by
      name;
  EOQ
}
