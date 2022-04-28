dashboard "kubernetes_deployment_detail" {

  title         = "Kubernetes Deployment Detail"
  documentation = file("./dashboards/deployment/docs/deployment_detail.md")

  tags = merge(local.deployment_common_tags, {
    type = "Detail"
  })

  input "deployment_uid" {
    title = "Select a deployment:"
    query = query.kubernetes_deployment_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kubernetes_deployment_default_namespace
      args = {
        uid = self.input.deployment_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_deployment_replica
      args = {
        uid = self.input.deployment_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_deployment_container_host_network
      args = {
        uid = self.input.deployment_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_deployment_container_host_pid
      args = {
        uid = self.input.deployment_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_deployment_container_host_ipc
      args = {
        uid = self.input.deployment_uid.value
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
        query = query.kubernetes_deployment_overview
        args = {
          uid = self.input.deployment_uid.value
        }
      }

      table {
        title = "Labels"
        width = 6
        query = query.kubernetes_deployment_labels
        args = {
          uid = self.input.deployment_uid.value
        }
      }
    }

    container {

      width = 6

      chart {
        title = "Replicas"
        query = query.kubernetes_deployment_replicas_detail
        type  = "donut"
        args = {
          uid = self.input.deployment_uid.value
        }

      }

    }

  }

  container {

    flow {
      title = "Deployment Hierarchy"
      query = query.kubernetes_deployment_tree
      args = {
        uid = self.input.deployment_uid.value
      }
    }

    table {
      column "UID" {
        display = "none"
      }

      title = "ReplicaSet Details"
      width = 6
      query = query.kubernetes_deployment_replicasets
      args = {
        uid = self.input.deployment_uid.value
      }
      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.kubernetes_replicaset_detail.url_path}?input.replicaset_uid={{.UID | @uri}}"
      }
    }

    table {
      title = "Pods Details"
      width = 6
      query = query.kubernetes_deployment_pods
      args = {
        uid = self.input.deployment_uid.value
      }
      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.kubernetes_pod_detail.url_path}?input.pod_uid={{.UID | @uri}}"
      }

    }


  }

  container {

    table {
      title = "Strategy"
      width = 6
      query = query.kubernetes_deployment_strategy
      args = {
        uid = self.input.deployment_uid.value
      }

    }

    table {
      title = "Conditions"
      width = 6
      query = query.kubernetes_deployment_conditions
      args = {
        uid = self.input.deployment_uid.value
      }

    }

  }

}

query "kubernetes_deployment_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'namespace', namespace,
        'context_name', context_name
      ) as tags
    from
      kubernetes_deployment
    order by
      title;
  EOQ
}

query "kubernetes_deployment_default_namespace" {
  sql = <<-EOQ
    select
      'Namespace' as label,
      initcap(namespace) as value,
      case when namespace = 'default' then 'alert' else 'ok' end as type
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_replica" {
  sql = <<-EOQ
    select
      replicas as value,
      'Replicas' as label,
      case when replicas < 3 then 'alert' else 'ok' end as type
    from
      kubernetes_deployment
    where
     uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_container_host_network" {
  sql = <<-EOQ
    select
      'Host Network Access' as label,
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_container_host_pid" {
  sql = <<-EOQ
    select
      'Host PID Sharing' as label,
      case when template -> 'spec' ->> 'hostPID' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostPID' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_container_host_ipc" {
  sql = <<-EOQ
    select
      'Host IPC Sharing' as label,
      case when template -> 'spec' ->> 'hostIPC' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostIPC' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      creation_timestamp as "Create Time",
      context_name as "Context Name"
    from
      kubernetes_deployment
    where
      uid = $1
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_deployment
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

query "kubernetes_deployment_conditions" {
  sql = <<-EOQ
    select
      c ->> 'lastTransitionTime' as "Last Transition Time",
      c ->> 'lastUpdateTime' as "Last Update Time",
      c ->> 'message' as "Message",
      c ->> 'reason' as "Reason",
      c ->> 'status' as "Status",
      c ->> 'type' as "Type"
    from
      kubernetes_deployment,
      jsonb_array_elements(conditions) as c
    where
      uid = $1
    order by
      c ->> 'lastTransitionTime' desc;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_strategy" {
  sql = <<-EOQ
    select
      strategy ->> 'type' as "Type",
      strategy -> 'rollingUpdate' ->> 'maxSurge' as "Max Surge",
      strategy -> 'rollingUpdate' ->> 'maxUnavailable' as "Max Unavailable"
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_replicas_detail" {
  sql = <<-EOQ
    select
      'available replicas' as label,
      available_replicas as value
    from
      kubernetes_deployment
    where
      uid = $1
    union all
    select
      'updated replicas' as label,
      updated_replicas as value
    from
      kubernetes_deployment
    where
      uid = $1
    union all
    select
      'ready replicas' as label,
      ready_replicas as value
    from
      kubernetes_deployment
    where
      uid = $1
    union all
    select
      'unavailable replicas' as label,
      unavailable_replicas as value
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_replicasets" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      min_ready_seconds as "Min Ready Seconds",
      creation_timestamp as "Create Time"
    from
      kubernetes_replicaset,
      jsonb_array_elements(owner_references) as owner
    where
      owner ->> 'uid' = $1
    order by
      name;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_pods" {
  sql = <<-EOQ
    select
      pod.name as "Name",
      pod.uid as "UID",
      pod.restart_policy as "Restart Policy",
      pod.node_name as "Node Name"
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      rs_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = rs.uid
    order by
      pod.name;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_tree" {
  sql = <<-EOQ

    -- This deployment
    select
      null as from_id,
      uid as id,
      name as title,
      0 as depth,
      'deployment' as category
    from
      kubernetes_deployment
    where
      uid = $1

    -- replicasets owned by the deployment
    union all
    select
      $1 as from_id,
      uid as id,
      name as title,
      1 as depth,
      'replicaset' as category
    from
      kubernetes_replicaset,
      jsonb_array_elements(owner_references) as owner
    where
      owner ->> 'uid' = $1

    -- Pods owned by the replicasets
    union all
    select
      pod_owner ->> 'uid'  as from_id,
      pod.uid as id,
      pod.name as title,
      2 as depth,
      'pod' as category
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      rs_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = rs.uid


    -- containers in Pods owned by the replicasets
    union all
    select
      pod.uid  as from_id,
      concat(pod.uid, '_', container ->> 'name') as id,
      container ->> 'name' as title,
      3 as depth,
      'container' as category
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      jsonb_array_elements(pod.containers) as container
    where
      rs_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = rs.uid


  EOQ


  param "uid" {}

}
