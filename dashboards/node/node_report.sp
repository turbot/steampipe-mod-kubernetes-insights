dashboard "kubernetes_node_report" {

  title         = "Kubernetes Node Report"
  documentation = file("./dashboards/node/docs/node_report.md")

  tags = merge(local.node_common_tags, {
    type = "Report"
  })

  container {

    card {
      query = query.kubernetes_node_count
      width = 2
    }

  }

  container {

    table {
      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.kubernetes_node_detail.url_path}?input.node_uid={{.UID | @uri}}"
      }

      query = query.kubernetes_node_table
    }
  }

}

query "kubernetes_node_count" {
  sql = <<-EOQ
    select
      count(*) as "Nodes"
    from
      kubernetes_node;
  EOQ
}

query "kubernetes_node_table" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      capacity ->> 'cpu' as "Capacity CPU",
      capacity ->> 'ephemeral-storage' as "Capacity Ephemeral Storage",
      capacity ->> 'memory' as "Capacity Memory",
      capacity ->> 'pods' as "Capacity Pods",
      context_name as "Context Name"
    from
      kubernetes_node
    order by
      name;
  EOQ
}
