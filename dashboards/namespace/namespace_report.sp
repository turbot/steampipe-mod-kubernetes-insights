dashboard "namespace_report" {

  title         = "Kubernetes Namespace Report"
  documentation = file("./dashboards/namespace/docs/namespace_report.md")

  tags = merge(local.namespace_common_tags, {
    type = "Report"
  })

  container {

    card {
      query = query.namespace_count
      width = 3
    }

  }

  container {

    table {
      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.namespace_detail.url_path}?input.namespace_uid={{.UID | @uri}}"
      }

      query = query.namespace_table
    }
  }

}

query "namespace_count" {
  sql = <<-EOQ
    select
      count(*) as "Namespaces"
    from
      kubernetes_namespace;
  EOQ
}

query "namespace_table" {
  sql = <<-EOQ
    select
      name as "Name",
      phase as "Phase",
      creation_timestamp as "Create Time",
      context_name as "Context Name",
      uid as "UID"
    from
      kubernetes_namespace
    order by
      name;
  EOQ
}
