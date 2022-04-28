dashboard "kubernetes_service_detail" {

  title         = "Kubernetes Service Detail"
  documentation = file("./dashboards/service/docs/service_detail.md")

  tags = merge(local.service_common_tags, {
    type = "Detail"
  })

  input "service_uid" {
    title = "Select a service:"
    query = query.kubernetes_service_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kubernetes_service_type
      args = {
        uid = self.input.service_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_service_default_namespace
      args = {
        uid = self.input.service_uid.value
      }
    }

  }

  container {

    container {

      width = 6

      table {
        title = "Overview"
        type  = "line"
        width = 6
        query = query.kubernetes_service_overview
        args = {
          uid = self.input.service_uid.value
        }
      }

      table {
        title = "Labels"
        width = 6
        query = query.kubernetes_service_labels
        args = {
          uid = self.input.service_uid.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Ports"
        query = query.kubernetes_service_ports
        args = {
          uid = self.input.service_uid.value
        }

      }

      table {
        title = "IP Details"
        query = query.kubernetes_service_ip_details
        args = {
          uid = self.input.service_uid.value
        }

      }

    }

  }

}

query "kubernetes_service_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'namespace', namespace,
        'context_name', context_name
      ) as tags
    from
      kubernetes_service
    order by
      title;
  EOQ
}

query "kubernetes_service_type" {
  sql = <<-EOQ
    select
      'Type' as label,
      initcap(type) as value
    from
      kubernetes_service
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_service_default_namespace" {
  sql = <<-EOQ
    select
      'Namespace' as label,
      initcap(namespace) as value,
      case when namespace = 'default' then 'alert' else 'ok' end as type
    from
      kubernetes_service
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_service_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      creation_timestamp as "Create Time",
      context_name as "Context Name"
    from
      kubernetes_service
    where
      uid = $1
  EOQ

  param "uid" {}
}

query "kubernetes_service_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_service
   where
     uid = $1
   )
   select
     key as "Key",
     value as "Value"
   from
     jsondata,
     json_each_text(label);
  EOQ

  param "uid" {}
}

query "kubernetes_service_ports" {
  sql = <<-EOQ
    select
      p ->> 'name' as "Name",
      p ->> 'port' as "Port",
      p ->> 'nodePort' as "Node Port",
      p ->> 'protocol' as "Protocol",
      p ->> 'targetPort' as "Target Port"
    from
      kubernetes_service,
      jsonb_array_elements(ports) as p
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_service_ip_details" {
  sql = <<-EOQ
    select
      cluster_ip as "Cluster IP",
      load_balancer_ip as "Load Balancer IP",
      external_ips as "External IPs"
    from
      kubernetes_service
    where
      uid = $1;
  EOQ

  param "uid" {}
}

