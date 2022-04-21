dashboard "kubernetes_node_dashboard" {

  title         = "kubernetes Node Dashboard"
  documentation = file("./dashboards/node/docs/node_dashboard.md")

  tags = merge(local.node_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.kubernetes_node_count
      width = 2
    }

    card {
      query = query.kubernetes_node_pod_count
      width = 2
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Nodes by Cluster"
      query = query.kubernetes_node_by_context_name
      type  = "column"
      width = 4
    }

    chart {
      title = "Nodes by Age"
      query = query.kubernetes_node_by_creation_month
      type  = "column"
      width = 4
    }
  }

}

# Card Queries

query "kubernetes_node_count" {
  sql = <<-EOQ
    select
      count(*) as "Nodes"
    from
      kubernetes_node;
  EOQ
}

query "kubernetes_node_pod_count" {
  sql = <<-EOQ
    select
      count(distinct p.name) as "Pods"
    from
      kubernetes_node as n
      left join kubernetes_pod as p on p.node_name = n.name
  EOQ
}

# Analysis Queries

query "kubernetes_node_by_context_name" {
  sql = <<-EOQ
    select
      context_name,
      count(name) as "nodes"
    from
      kubernetes_node
    group by
      context_name
    order by
      context_name;
  EOQ
}

query "kubernetes_node_by_creation_month" {
  sql = <<-EOQ
    with nodes as (
      select
        title,
        creation_timestamp,
        to_char(creation_timestamp,
          'YYYY-MM') as creation_month
      from
        kubernetes_node
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
                from nodes)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    nodes_by_month as (
      select
        creation_month,
        count(*)
      from
        nodes
      group by
        creation_month
    )
    select
      months.month,
      nodes_by_month.count
    from
      months
      left join nodes_by_month on months.month = nodes_by_month.creation_month
    order by
      months.month;
  EOQ
}
