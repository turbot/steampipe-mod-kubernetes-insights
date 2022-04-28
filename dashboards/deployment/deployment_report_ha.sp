dashboard "kubernetes_deployment_ha_report" {

  title         = "Kubernetes Deployment HA Report"
  documentation = file("./dashboards/deployment/docs/deployment_report_ha.md")

  tags = merge(local.deployment_common_tags, {
    type     = "Report"
    category = "Replicas"
  })

  container {

    card {
      query = query.kubernetes_deployment_count
      width = 2
    }

    card {
      query = query.kubernetes_deployment_replica_count
      width = 2
    }

  }

  table {
    column "UID" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.kubernetes_deployment_detail.url_path}?input.deployment_uid={{.UID | @uri}}"
    }

    query = query.kubernetes_deployment_replicas_table
  }

}

query "kubernetes_deployment_replicas_table" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      available_replicas as "Available Replicas",
      updated_replicas as "Updated Replicas",
      ready_replicas as "Ready Replicas",
      unavailable_replicas as "Unavailable Replicas",
      context_name as "Context Name"
    from
      kubernetes_deployment
    order by
      name;
  EOQ
}
