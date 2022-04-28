dashboard "kubernetes_namespace_report" {

  title         = "Kubernetes Namespace Report"
  documentation = file("./dashboards/namespace/docs/namespace_report.md")

  tags = merge(local.namespace_common_tags, {
    type = "Report"
  })

  container {

    card {
      query = query.kubernetes_namespace_count
      width = 2
    }

  }

  container {

    table {
      column "UID" {
        display = "none"
      }

      query = query.kubernetes_namespace_table
    }
  }

}

query "kubernetes_namespace_count" {
  sql = <<-EOQ
    select
      count(*) as "Namespaces"
    from
      kubernetes_namespace;
  EOQ
}

query "kubernetes_namespace_table" {
  sql = <<-EOQ
    select
      name as "Namespace Name",
      uid as "UID",
      phase as "Phase",
      creation_timestamp as "Create Time",
      context_name as "Context Name"
    from
      kubernetes_namespace
    order by
      name;
  EOQ
}
