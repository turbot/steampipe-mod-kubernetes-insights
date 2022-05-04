dashboard "kubernetes_statefulset_age_report" {

  title         = "Kubernetes StatefulSet Age Report"
  documentation = file("./dashboards/statefulset/docs/statefulset_report_age.md")

  tags = merge(local.statefulset_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      width = 2
      query = query.kubernetes_statefulset_count
    }

    card {
      type  = "info"
      width = 2
      query = query.kubernetes_statefulset_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.kubernetes_statefulset_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.kubernetes_statefulset_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.kubernetes_statefulset_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.kubernetes_statefulset_1_year_count
    }

  }

  table {
    column "UID" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.kubernetes_statefulset_detail.url_path}?input.statefulset_uid={{.UID | @uri}}"
    }

    query = query.kubernetes_statefulset_age_table
  }

}

query "kubernetes_statefulset_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      kubernetes_stateful_set
    where
      creation_timestamp > now() - '1 days' :: interval;
  EOQ
}

query "kubernetes_statefulset_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      kubernetes_stateful_set
    where
      creation_timestamp between symmetric now() - '1 days' :: interval
      and now() - '30 days' :: interval;
  EOQ
}

query "kubernetes_statefulset_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      kubernetes_stateful_set
    where
      creation_timestamp between symmetric now() - '30 days' :: interval
      and now() - '90 days' :: interval;
  EOQ
}

query "kubernetes_statefulset_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      kubernetes_stateful_set
    where
      creation_timestamp between symmetric (now() - '90 days'::interval)
      and (now() - '365 days'::interval);
  EOQ
}

query "kubernetes_statefulset_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      kubernetes_stateful_set
    where
      creation_timestamp <= now() - '1 year' :: interval;
  EOQ
}

query "kubernetes_statefulset_age_table" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      now()::date - creation_timestamp::date as "Age in Days",
      creation_timestamp as "Create Time",
      context_name as "Context Name"
    from
      kubernetes_stateful_set
    order by
      name;
  EOQ
}
