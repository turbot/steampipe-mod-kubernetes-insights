dashboard "node_report" {

  title         = "Kubernetes Node Report"
  documentation = file("./dashboards/node/docs/node_report.md")

  tags = merge(local.node_common_tags, {
    type = "Report"
  })

  container {

    card {
      query = query.node_count
      width = 3
    }

  }

  container {

    table {
      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.node_detail.url_path}?input.node_uid={{.UID | @uri}}"
      }

      query = query.node_table
    }
  }

}

query "node_count" {
  sql = <<-EOQ
    select
      count(*) as "Nodes"
    from
      kubernetes_node;
  EOQ
}

query "node_table" {
  sql = <<-EOQ
    select
      name as "Name",
      capacity ->> 'cpu' as "Capacity CPU",
      capacity ->> 'ephemeral-storage' as "Capacity Ephemeral Storage",
      capacity ->> 'memory' as "Capacity Memory",
      capacity ->> 'pods' as "Capacity Pods",
      context_name as "Context Name",
      uid as "UID"
    from
      kubernetes_node
    order by
      name;
  EOQ
}
