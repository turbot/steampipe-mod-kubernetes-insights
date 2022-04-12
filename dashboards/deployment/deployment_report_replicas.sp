dashboard "kubernetes_deployment_replicas_report" {

  title         = "Kubernetes Deployment Replicas Report"
  documentation = file("./dashboards/deployment/docs/deployment_report_replicas.md")

  tags = merge(local.deployment_common_tags, {
    type     = "Report"
    category = "Replicas"
  })

  container {

    card {
      query = query.kubernetes_deployment_replicas_count
      width = 2
    }

    card {
      query = query.kubernetes_deployment_available_replicas_count
      width = 2
    }

    card {
      query = query.kubernetes_deployment_updated_replicas_count
      width = 2
    }

    card {
      query = query.kubernetes_deployment_ready_replicas_count
      width = 2
    }

    card {
      query = query.kubernetes_deployment_status_replicas_count
      width = 2
    }

    card {
      query = query.kubernetes_deployment_unavailable_replicas_count
      width = 2
    }

  }

  table {
    column "UID" {
      display = "none"
    }

    column "Deployment Name" {
      href = "${dashboard.kubernetes_deployment_detail.url_path}?input.deployment_uid={{.UID | @uri}}"
    }

    query = query.kubernetes_deployment_replicas_table
  }

}

query "kubernetes_deployment_replicas_count" {
  sql = <<-EOQ
    select
      sum(replicas) as value,
      'Replicas' as label
    from
      kubernetes_deployment;
  EOQ
}

query "kubernetes_deployment_available_replicas_count" {
  sql = <<-EOQ
    select
      sum(available_replicas) as value,
      'Available Replicas' as label
    from
      kubernetes_deployment;
  EOQ
}
query "kubernetes_deployment_updated_replicas_count" {
  sql = <<-EOQ
    select
      sum(updated_replicas) as value,
      'Updated Replicas' as label
    from
      kubernetes_deployment;
  EOQ
}
query "kubernetes_deployment_ready_replicas_count" {
  sql = <<-EOQ
    select
      sum(ready_replicas) as value,
      'Ready Replicas' as label
    from
      kubernetes_deployment;
  EOQ
}
query "kubernetes_deployment_status_replicas_count" {
  sql = <<-EOQ
    select
      sum(status_replicas) as value,
      'Status Replicas' as label
    from
      kubernetes_deployment;
  EOQ
}
query "kubernetes_deployment_unavailable_replicas_count" {
  sql = <<-EOQ
    select
      sum(unavailable_replicas) as value,
      'Unavailable Replicas' as label
    from
      kubernetes_deployment;
  EOQ
}
query "kubernetes_deployment_replicas_table" {
  sql = <<-EOQ
    select
      name as "Deployment Name",
      uid as "UID",
      available_replicas as "Available Replicas",
      updated_replicas as "Updated Replicas",
      ready_replicas as "Ready Replicas",
      status_replicas as "Status Replicas",
      unavailable_replicas as "Unavailable Replicas",
      context_name as "Context Name"
    from
      kubernetes_deployment
    order by
      name;
  EOQ
}
