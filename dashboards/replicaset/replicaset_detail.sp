dashboard "kubernetes_replicaset_detail" {

  title         = "Kubernetes ReplicaSet Detail"
  documentation = file("./dashboards/replicaset/docs/replicaset_detail.md")

  tags = merge(local.replicaset_common_tags, {
    type = "Detail"
  })

  input "replicaset_uid" {
    title = "Select a replicaSet:"
    query = query.kubernetes_replicaset_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kubernetes_replicaset_default_namespace
      args = {
        uid = self.input.replicaset_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_replicaset_container_host_network
      args = {
        uid = self.input.replicaset_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_replicaset_container_host_pid
      args = {
        uid = self.input.replicaset_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_replicaset_container_host_ipc
      args = {
        uid = self.input.replicaset_uid.value
      }
    }

  }

  container {

    table {
      title = "Overview"
      type  = "line"
      width = 3
      query = query.kubernetes_replicaset_overview
      args = {
        uid = self.input.replicaset_uid.value
      }
    }

    table {
      title = "Labels"
      width = 3
      query = query.kubernetes_replicaset_labels
      args = {
        uid = self.input.replicaset_uid.value
      }
    }

    table {
      title = "Annotations"
      width = 6
      query = query.kubernetes_replicaset_annotations
      args = {
        uid = self.input.replicaset_uid.value
      }
    }
  }

  container {

    chart {
      title = "Replicas"
      width = 4
      query = query.kubernetes_replicaset_replicas_detail
      type  = "donut"
      args = {
        uid = self.input.replicaset_uid.value
      }

    }

    flow {
      title = "ReplicaSet Hierarchy"
      width = 8
      query = query.kubernetes_replicaset_tree
      args = {
        uid = self.input.replicaset_uid.value
      }
    }
  }
  container {

    table {
      title = "Pods Details"
      width = 6
      query = query.kubernetes_replicaset_pods
      args = {
        uid = self.input.replicaset_uid.value
      }
      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.kubernetes_pod_detail.url_path}?input.pod_uid={{.UID | @uri}}"
      }

    }

    table {
      title = "Conditions"
      width = 6
      query = query.kubernetes_replicaset_conditions
      args = {
        uid = self.input.replicaset_uid.value
      }

    }

  }

}

query "kubernetes_replicaset_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'namespace', namespace,
        'context_name', context_name
      ) as tags
    from
      kubernetes_replicaset
    order by
      title;
  EOQ
}

query "kubernetes_replicaset_default_namespace" {
  sql = <<-EOQ
    select
      'Namespace' as label,
      initcap(namespace) as value,
      case when namespace = 'default' then 'alert' else 'ok' end as type
    from
      kubernetes_replicaset
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_replicaset_container_host_network" {
  sql = <<-EOQ
    select
      'Host Network Access' as label,
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_replicaset
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_replicaset_container_host_pid" {
  sql = <<-EOQ
    select
      'Host PID Sharing' as label,
      case when template -> 'spec' ->> 'hostPID' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostPID' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_replicaset
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_replicaset_container_host_ipc" {
  sql = <<-EOQ
    select
      'Host IPC Sharing' as label,
      case when template -> 'spec' ->> 'hostIPC' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostIPC' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_replicaset
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_replicaset_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      creation_timestamp as "Create Time",
      context_name as "Context Name"
    from
      kubernetes_replicaset
    where
      uid = $1
  EOQ

  param "uid" {}
}

query "kubernetes_replicaset_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_replicaset
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

query "kubernetes_replicaset_annotations" {
  sql = <<-EOQ
    with jsondata as (
   select
     annotations::json as annotation
   from
     kubernetes_replicaset
   where
     uid = $1
   )
   select
     key as "Key",
     value as "Value"
   from
     jsondata,
     json_each_text(annotation);
  EOQ

  param "uid" {}
}

query "kubernetes_replicaset_conditions" {
  sql = <<-EOQ
    select
      c ->> 'lastTransitionTime' as "Last Transition Time",
      c ->> 'lastUpdateTime' as "Last Update Time",
      c ->> 'message' as "Message",
      c ->> 'reason' as "Reason",
      c ->> 'status' as "Status",
      c ->> 'type' as "Type"
    from
      kubernetes_replicaset,
      jsonb_array_elements(conditions) as c
    where
      uid = $1
    order by
      c ->> 'lastTransitionTime' desc;
  EOQ

  param "uid" {}
}

query "kubernetes_replicaset_replicas_detail" {
  sql = <<-EOQ
    select
      'status replicas' as label,
      status_replicas as value
    from
      kubernetes_replicaset
    where
      uid = $1
    union all
    select
      'fully labeled replicas' as label,
      fully_labeled_replicas as value
    from
      kubernetes_replicaset
    where
      uid = $1
    union all
    select
      'ready replicas' as label,
      ready_replicas as value
    from
      kubernetes_replicaset
    where
      uid = $1
    union all
    select
      'available replicas' as label,
      available_replicas as value
    from
      kubernetes_replicaset
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_replicaset_pods" {
  sql = <<-EOQ
    select
      pod.name as "Name",
      pod.uid as "UID",
      pod.restart_policy as "Restart Policy",
      pod.node_name as "Node Name"
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = $1
    order by
      pod.name;
  EOQ

  param "uid" {}
}

query "kubernetes_replicaset_tree" {
  sql = <<-EOQ

    -- This replicaset
    select
      null as from_id,
      uid as id,
      name as title,
      0 as depth,
      'job' as category
    from
      kubernetes_replicaset
    where
      uid = $1

    -- Pods owned by the replicaset
    union all
    select
      pod_owner ->> 'uid'  as from_id,
      pod.uid as id,
      pod.name as title,
      1 as depth,
      'pod' as category
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = $1


    -- containers in Pods owned by the replicaset
    union all
    select
      pod.uid  as from_id,
      concat(pod.uid, '_', container ->> 'name') as id,
      container ->> 'name' as title,
      2 as depth,
      'container' as category
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      jsonb_array_elements(pod.containers) as container
    where
      pod_owner ->> 'uid' = $1
  EOQ


  param "uid" {}

}
