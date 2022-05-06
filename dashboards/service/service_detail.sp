dashboard "kubernetes_service_detail" {

  title         = "Kubernetes Service Detail"
  documentation = file("./dashboards/service/docs/service_detail.md")

  tags = merge(local.service_common_tags, {
    type = "Detail"
  })

  input "service_uid" {
    title = "Select a Service:"
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
        title = "Annotations"
        query = query.kubernetes_service_annotations
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

    container {

      flow {
        title = "Service Port Analysis"
        query = query.kubernetes_service_tree
        args = {
          uid = self.input.service_uid.value
        }
      }
    }

    container {

      table {
        title = "Ports"
        width = 6
        query = query.kubernetes_service_ports
        args = {
          uid = self.input.service_uid.value
        }

      }

      table {
        title = "Pods"
        width = 6
        query = query.kubernetes_service_pods
        args = {
          uid = self.input.service_uid.value
        }

        column "UID" {
          display = "none"
        }

        column "Name" {
          href = "${dashboard.kubernetes_pod_detail.url_path}?input.pod_uid={{.UID | @uri}}"
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
      uid = $1;
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
     json_each_text(label)
   order by
     key;
  EOQ

  param "uid" {}
}

query "kubernetes_service_annotations" {
  sql = <<-EOQ
    with jsondata as (
   select
     annotations::json as annotation
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
     json_each_text(annotation)
   order by
     key;
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
      uid = $1
    order by
      p ->> 'name';
  EOQ

  param "uid" {}
}

query "kubernetes_service_pods" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      restart_policy as "Restart Policy",
      node_name as "Node Name"
    from
      kubernetes_pod
    where
      selector_search in (select selector_query from kubernetes_service where uid = $1)
    order by
      name;
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

query "kubernetes_service_tree" {
  sql = <<-EOQ
  with pods as (
    select
      uid as pod_uid,
      title as pod_title
    from
      kubernetes_pod
    where
      selector_search in (select selector_query from kubernetes_service where uid = $1)
  ),
  services as (
    select
      uid,
      title,
      pod_uid,
      pod_title,
      selector_query,
      p ->> 'protocol' as protocol_number,
      concat(p ->> 'port','/', p ->> 'protocol') as port,
      concat(p ->> 'targetPort','/', p ->> 'protocol') as targetPort
    from
      pods,
      kubernetes_service,
      jsonb_array_elements(ports) as p
    where
      uid = $1
    )

  -- Ports
    select
      port as id,
      port as title,
      'port' as category,
      null as from_id,
      null as to_id
    from
      services

    -- service
    union all
    select
      distinct title as id,
      title as title,
      'service' as category,
      null as from_id,
      null as to_id
    from
      services

    -- targetPorts
    union all
    select
      concat(targetPort,' (Target Port)') as id,
      targetPort as title,
      'targetPort' as category,
      null as from_id,
      null as to_id
    from
      services

    -- pods
    union all
    select
      distinct pod_title as id,
      pod_title as title,
      'pod' as category,
      null as from_id,
      null as to_id
    from
      services

    -- port -> service
    union select
      null as id,
      null as title,
      protocol_number as category,
      port as from_id,
      title as to_id
    from services

   -- service -> target
    union select
      null as id,
      null as title,
      protocol_number as category,
      title as from_id,
      concat(targetPort,' (Target Port)') as to_id
    from services

   -- target -> pod
    union select
      null as id,
      null as title,
      protocol_number as category,
      concat(targetPort,' (Target Port)') as from_id,
      pod_title as to_id
    from services
  EOQ

  param "uid" {}

}
