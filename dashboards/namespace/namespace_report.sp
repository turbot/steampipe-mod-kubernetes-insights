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

      column "Name" {
        href = "${dashboard.kubernetes_namespace_detail.url_path}?input.namespace_uid={{.UID | @uri}}"
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
