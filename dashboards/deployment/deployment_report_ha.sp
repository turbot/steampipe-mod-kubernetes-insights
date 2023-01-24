dashboard "deployment_ha_report" {

  title         = "Kubernetes Deployment HA Report"
  documentation = file("./dashboards/deployment/docs/deployment_report_ha.md")

  tags = merge(local.deployment_common_tags, {
    type     = "Report"
    category = "High Availability"
  })

  container {

    card {
      query = query.deployment_count
      width = 3
    }

    card {
      query = query.deployment_replica_count
      width = 3
    }

  }

  table {
    column "UID" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.deployment_detail.url_path}?input.deployment_uid={{.UID | @uri}}"
    }

    query = query.deployment_replicas_table
  }

}

query "deployment_replicas_table" {
  sql = <<-EOQ
    select
      name as "Name",
      replicas as "Replicas",
      available_replicas as "Available Replicas",
      updated_replicas as "Updated Replicas",
      ready_replicas as "Ready Replicas",
      unavailable_replicas as "Unavailable Replicas",
      context_name as "Context Name",
      uid as "UID"
    from
      kubernetes_deployment
    order by
      name;
  EOQ
}
