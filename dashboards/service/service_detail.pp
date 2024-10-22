dashboard "service_detail" {

  title         = "Kubernetes Service Detail"
  documentation = file("./dashboards/service/docs/service_detail.md")

  tags = merge(local.service_common_tags, {
    type = "Detail"
  })

  input "service_uid" {
    title = "Select a Service:"
    query = query.service_input
    width = 4
  }

  container {

    card {
      width = 3
      query = query.service_type
      args = {
        uid = self.input.service_uid.value
      }
    }

    card {
      width = 3
      query = query.service_default_namespace
      args = {
        uid = self.input.service_uid.value
      }
      href = "/kubernetes_insights.dashboard.namespace_detail?input.namespace_uid={{.'UID' | @uri}}"
    }

  }

  with "ingresses_for_service" {
    query = query.ingresses_for_service
    args  = [self.input.service_uid.value]
  }

  with "pods_for_service" {
    query = query.pods_for_service
    args  = [self.input.service_uid.value]
  }

  with "deployments_for_service" {
    query = query.deployments_for_service
    args  = [self.input.service_uid.value]
  }

  with "replicasets_for_service" {
    query = query.replicasets_for_service
    args  = [self.input.service_uid.value]
  }

  with "statefulsets_for_service" {
    query = query.statefulsets_for_service
    args  = [self.input.service_uid.value]
  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.service
        args = {
          service_uids = [self.input.service_uid.value]
        }
      }

      node {
        base = node.service_load_balancer
        args = {
          service_uids = [self.input.service_uid.value]
        }
      }

      node {
        base = node.ingress_rule
        args = {
          ingress_uids = with.ingresses_for_service.rows[*].uid
        }
      }

      node {
        base = node.ingress
        args = {
          ingress_uids = with.ingresses_for_service.rows[*].uid
        }
      }

      node {
        base = node.deployment
        args = {
          deployment_uids = with.deployments_for_service.rows[*].uid
        }
      }

      node {
        base = node.replicaset
        args = {
          replicaset_uids = with.replicasets_for_service.rows[*].uid
        }
      }

      node {
        base = node.statefulset
        args = {
          statefulset_uids = with.statefulsets_for_service.rows[*].uid
        }
      }

      node {
        base = node.pod
        args = {
          pod_uids = with.pods_for_service.rows[*].uid
        }
      }

      node {
        base = node.ingress_load_balancer
        args = {
          ingress_uids = with.ingresses_for_service.rows[*].uid
        }
      }

      edge {
        base = edge.ingress_load_balancer_to_ingress
        args = {
          ingress_uids = with.ingresses_for_service.rows[*].uid
        }
      }

      edge {
        base = edge.ingress_to_ingress_rule
        args = {
          ingress_uids = with.ingresses_for_service.rows[*].uid
        }
      }

      edge {
        base = edge.ingress_rule_to_service
        args = {
          ingress_uids = with.ingresses_for_service.rows[*].uid
        }
      }

      edge {
        base = edge.service_load_balancer_to_service
        args = {
          service_uids = [self.input.service_uid.value]
        }
      }

      edge {
        base = edge.service_to_deployment
        args = {
          service_uids = [self.input.service_uid.value]
        }
      }

      edge {
        base = edge.deployment_to_replicaset
        args = {
          deployment_uids = with.deployments_for_service.rows[*].uid
        }
      }

      edge {
        base = edge.service_to_statefulset
        args = {
          service_uids = [self.input.service_uid.value]
        }
      }

      edge {
        base = edge.replicaset_to_pod
        args = {
          replicaset_uids = with.replicasets_for_service.rows[*].uid
        }
      }

      edge {
        base = edge.statefulset_to_pod
        args = {
          statefulset_uids = with.statefulsets_for_service.rows[*].uid
        }
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
        query = query.service_overview
        args = {
          uid = self.input.service_uid.value
        }

        column "Namespace" {
          href = "/kubernetes_insights.dashboard.namespace_detail?input.namespace_uid={{.'Namespace UID' | @uri}}"
        }

        column "Namespace UID" {
          display = "none"
        }
      }

      table {
        title = "Labels"
        width = 6
        query = query.service_labels
        args = {
          uid = self.input.service_uid.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Annotations"
        query = query.service_annotations
        args = {
          uid = self.input.service_uid.value
        }
      }

      table {
        title = "IP Details"
        query = query.service_ip_details
        args = {
          uid = self.input.service_uid.value
        }

      }

    }

    container {

      flow {
        title = "Service Port Analysis"
        query = query.service_tree
        args = {
          uid = self.input.service_uid.value
        }
      }
    }

    container {

      table {
        title = "Ports"
        width = 6
        query = query.service_ports
        args = {
          uid = self.input.service_uid.value
        }

      }

      table {
        title = "Pods"
        width = 6
        query = query.service_pods_detail
        args = {
          uid = self.input.service_uid.value
        }

        column "UID" {
          display = "none"
        }

        column "Name" {
          href = "${dashboard.pod_detail.url_path}?input.pod_uid={{.UID | @uri}}"
        }
      }
    }

  }

}

# Input queries

query "service_input" {
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

# Card queries

query "service_type" {
  sql = <<-EOQ
    select
      'Type' as label,
      type as value
    from
      kubernetes_service
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "service_default_namespace" {
  sql = <<-EOQ
    select
      'Namespace' as label,
      initcap(namespace) as value,
      case when namespace = 'default' then 'alert' else 'ok' end as type,
      n.uid as "UID"
    from
      kubernetes_service as s,
      kubernetes_namespace as n
    where
      n.name = s.namespace
      and n.context_name = s.context_name
      and s.uid = $1;
  EOQ

  param "uid" {}
}

# With queries

query "pods_for_service" {
  sql = <<-EOQ
    select
      p.uid as uid
    from
      kubernetes_service as s,
      kubernetes_pod as p
     where
      p.selector_search = s.selector_query
      and s.context_name = p.context_name
      and s.uid = $1;
  EOQ
}

query "replicasets_for_service" {
  sql = <<-EOQ
    select
      pod_owner ->> 'uid' as uid
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      kubernetes_service as s
    where
      s.uid = $1
      and s.context_name = pod.context_name
      and pod.selector_search = s.selector_query;
  EOQ
}

query "statefulsets_for_service" {
  sql = <<-EOQ
    select
      st.uid as uid
    from
      kubernetes_stateful_set as st,
      kubernetes_service as s
    where
      st.service_name = s.name
      and s.context_name = st.context_name
      and s.uid = $1
    union
    select
      distinct st.uid as uid
    from
      kubernetes_stateful_set as st,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      kubernetes_service as s
    where
      s.uid = $1
      and s.context_name = st.context_name
      and pod_owner ->> 'uid' = st.uid
      and pod.selector_search = s.selector_query;
  EOQ
}

query "deployments_for_service" {
  sql = <<-EOQ
    select
      rs_owner ->> 'uid' as uid
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      kubernetes_service as s
    where
      s.uid = $1
      and s.context_name = rs.context_name
      and pod_owner ->> 'uid' = rs.uid
      and pod.selector_search = s.selector_query;
  EOQ
}

query "ingresses_for_service" {
  sql = <<-EOQ
    select
      i.uid
    from
      kubernetes_service as s,
      kubernetes_ingress as i,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements(r -> 'http' -> 'paths') as p
    where
      s.name = p -> 'backend' -> 'service' ->> 'name'
      and s.context_name = i.context_name
      and s.uid = $1;
  EOQ
}

# Other queries

query "service_overview" {
  sql = <<-EOQ
    select
      s.name as "Name",
      s.uid as "UID",
      s.creation_timestamp as "Create Time",
      n.uid as "Namespace UID",
      n.name as "Namespace",
      s.context_name as "Context Name"
    from
      kubernetes_service as s,
      kubernetes_namespace as n
    where
      n.name = s.namespace
      and n.context_name = s.context_name
      and s.uid = $1;
  EOQ

  param "uid" {}
}

query "service_labels" {
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

query "service_annotations" {
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

query "service_ports" {
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

query "service_pods_detail" {
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

query "service_ip_details" {
  sql = <<-EOQ
    select
      cluster_ip as "Cluster IP",
      l ->> 'ip' as "Load Balancer IP",
      external_ips as "External IPs"
    from
      kubernetes_service,
      jsonb_array_elements(load_balancer_ingress) as l
    where
      uid = $1
    union
    select
      cluster_ip as "Cluster IP",
      load_balancer_ingress::text as "Load Balancer IP",
      external_ips as "External IPs"
    from
      kubernetes_service
    where
      uid = $1 and load_balancer_ingress is null;
  EOQ

  param "uid" {}
}

query "service_tree" {
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
      cluster_ip,
      external_ips,
      selector_query,
      l as lb,
      p ->> 'protocol' as protocol_number,
      concat(p ->> 'port','/', p ->> 'protocol') as port,
      concat(p ->> 'targetPort','/', p ->> 'protocol') as targetPort
    from
      pods,
      kubernetes_service,
      jsonb_array_elements(ports) as p,
      jsonb_array_elements(load_balancer_ingress) as l
    where
      uid = $1
    union
    select
      uid,
      title,
      pod_uid,
      pod_title,
      cluster_ip,
      external_ips,
      selector_query,
      load_balancer_ingress as lb,
      p ->> 'protocol' as protocol_number,
      concat(p ->> 'port','/', p ->> 'protocol') as port,
      concat(p ->> 'targetPort','/', p ->> 'protocol') as targetPort
    from
      pods,
      kubernetes_service,
      jsonb_array_elements(ports) as p
    where
      uid = $1
      and load_balancer_ingress is null
    )

  -- LB
    select
      lb::text as id,
      lb ->> 'ip' as title,
      'lb' as category,
      null as from_id,
      null as to_id
    from
      services

  -- EIP
    union all
    select
      eip as id,
      eip as title,
      'external_ip' as category,
      null as from_id,
      null as to_id
    from
      services,
      jsonb_array_elements_text(external_ips) as eip

  -- ClusterIP
    union all
    select
      cluster_ip as id,
      cluster_ip as title,
      'cluster_ip' as category,
      null as from_id,
      null as to_id
    from
      services

  -- Ports
    union all
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

    -- externalIP -> port
    union select
      null as id,
      null as title,
      'external_ip' as category,
      eip as from_id,
      port as to_id
    from services,
    jsonb_array_elements_text(external_ips) as eip

    -- clusterIP -> port
    union select
      null as id,
      null as title,
      'cluster_ip' as category,
      cluster_ip as from_id,
      port as to_id
    from services

    -- lb -> port
    union select
      null as id,
      null as title,
      'lb' as category,
      lb::text as from_id,
      port as to_id
    from services

    -- port -> service
    union select
      null as id,
      null as title,
      'port' as category,
      port as from_id,
      title as to_id
    from services

   -- service -> target
    union select
      null as id,
      null as title,
      'service' as category,
      title as from_id,
      concat(targetPort,' (Target Port)') as to_id
    from services

   -- target -> pod
    union select
      null as id,
      null as title,
      'targetPort' as category,
      concat(targetPort,' (Target Port)') as from_id,
      pod_title as to_id
    from services
  EOQ

  param "uid" {}

}
