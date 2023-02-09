dashboard "pod_detail" {

  title         = "Kubernetes Pod Detail"
  documentation = file("./dashboards/pod/docs/pod_detail.md")

  tags = merge(local.pod_common_tags, {
    type = "Detail"
  })

  input "pod_uid" {
    title = "Select a Pod:"
    query = query.pod_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.pod_status
      args = {
        uid = self.input.pod_uid.value
      }
    }

    card {
      width = 2
      query = query.pod_container
      args = {
        uid = self.input.pod_uid.value
      }
    }

    card {
      width = 2
      query = query.pod_default_namespace
      args = {
        uid = self.input.pod_uid.value
      }
      href = "/kubernetes_insights.dashboard.namespace_detail?input.namespace_uid={{.'UID' | @uri}}"
    }

    card {
      width = 2
      query = query.pod_container_host_network
      args = {
        uid = self.input.pod_uid.value
      }
    }

    card {
      width = 2
      query = query.pod_container_host_pid
      args = {
        uid = self.input.pod_uid.value
      }
    }

    card {
      width = 2
      query = query.pod_container_host_ipc
      args = {
        uid = self.input.pod_uid.value
      }
    }

  }

  with "containers_for_pod" {
    query = query.containers_for_pod
    args  = [self.input.pod_uid.value]
  }

  with "init_containers_for_pod" {
    query = query.init_containers_for_pod
    args  = [self.input.pod_uid.value]
  }

  with "persistent_volumes_for_pod" {
    query = query.persistent_volumes_for_pod
    args  = [self.input.pod_uid.value]
  }

  with "configmaps_for_pod" {
    query = query.configmaps_for_pod
    args  = [self.input.pod_uid.value]
  }

  with "secrets_for_pod" {
    query = query.secrets_for_pod
    args  = [self.input.pod_uid.value]
  }

  with "persistent_volume_claims" {
    query = query.pod_persistent_volume_claims
    args  = [self.input.pod_uid.value]
  }

  with "daemonsets_for_pod" {
    query = query.daemonsets_for_pod
    args  = [self.input.pod_uid.value]
  }

  with "jobs_for_pod" {
    query = query.jobs_for_pod
    args  = [self.input.pod_uid.value]
  }

  with "replicasets_for_pod" {
    query = query.replicasets_for_pod
    args  = [self.input.pod_uid.value]
  }

  with "statefulsets_for_pod" {
    query = query.statefulsets_for_pod
    args  = [self.input.pod_uid.value]
  }

  with "deployments_for_pod" {
    query = query.deployments_for_pod
    args  = [self.input.pod_uid.value]
  }

  with "service_accounts_for_pod" {
    query = query.service_accounts_for_pod
    args  = [self.input.pod_uid.value]
  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.pod
        args = {
          pod_uids = [self.input.pod_uid.value]
        }
      }

      node {
        base = node.service_account
        args = {
          service_account_uids = with.service_accounts_for_pod.rows[*].uid
        }
      }

      node {
        base = node.configmap
        args = {
          configmap_uids = with.configmaps_for_pod.rows[*].uid
        }
      }

      node {
        base = node.secret
        args = {
          secret_uids = with.secrets_for_pod.rows[*].uid
        }
      }

      node {
        base = node.container
        args = {
          container_names = with.containers_for_pod.rows[*].name
        }
      }

      node {
        base = node.init_container
        args = {
          init_container_names = with.init_containers_for_pod.rows[*].name
        }
      }

      node {
        base = node.container_volume
        args = {
          container_names = with.containers_for_pod.rows[*].name
        }
      }

      node {
        base = node.persistent_volume_claim
        args = {
          persistent_volume_claim_uids = with.persistent_volume_claims.rows[*].uid
        }
      }

      node {
        base = node.persistent_volume
        args = {
          persistent_volume_uids = with.persistent_volumes_for_pod.rows[*].uid
        }
      }

      node {
        base = node.daemonset
        args = {
          daemonset_uids = with.daemonsets_for_pod.rows[*].uid
        }
      }

      node {
        base = node.job
        args = {
          job_uids = with.jobs_for_pod.rows[*].uid
        }
      }

      node {
        base = node.replicaset
        args = {
          replicaset_uids = with.replicasets_for_pod.rows[*].uid
        }
      }

      node {
        base = node.deployment
        args = {
          deployment_uids = with.deployments_for_pod.rows[*].uid
        }
      }

      node {
        base = node.statefulset
        args = {
          statefulset_uids = with.statefulsets_for_pod.rows[*].uid
        }
      }

      edge {
        base = edge.pod_to_service_account
        args = {
          pod_uids = [self.input.pod_uid.value]
        }
      }

      edge {
        base = edge.container_volume_to_configmap
        args = {
          pod_uids = [self.input.pod_uid.value]
        }
      }

      edge {
        base = edge.container_volume_to_secret
        args = {
          pod_uids = [self.input.pod_uid.value]
        }
      }

      edge {
        base = edge.container_volume_to_persistent_volume_claim
        args = {
          pod_uids = [self.input.pod_uid.value]
        }
      }

      edge {
        base = edge.persistent_volume_claim_to_persistent_volume
        args = {
          persistent_volume_claim_uids = with.persistent_volume_claims.rows[*].uid
        }
      }

      edge {
        base = edge.pod_to_container
        args = {
          pod_uids = [self.input.pod_uid.value]
        }
      }

      edge {
        base = edge.pod_to_init_container
        args = {
          pod_uids = [self.input.pod_uid.value]
        }
      }

      edge {
        base = edge.job_to_pod
        args = {
          job_uids = with.jobs_for_pod.rows[*].uid
        }
      }

      edge {
        base = edge.replicaset_to_pod
        args = {
          replicaset_uids = with.replicasets_for_pod.rows[*].uid
        }
      }

      edge {
        base = edge.deployment_to_replicaset
        args = {
          deployment_uids = with.deployments_for_pod.rows[*].uid
        }
      }

      edge {
        base = edge.daemonset_to_pod
        args = {
          daemonset_uids = with.daemonsets_for_pod.rows[*].uid
        }
      }

      edge {
        base = edge.statefulset_to_pod
        args = {
          statefulset_uids = with.statefulsets_for_pod.rows[*].uid
        }
      }

      edge {
        base = edge.container_to_container_volume
        args = {
          container_names = with.containers_for_pod.rows[*].name
        }
      }

    }
  }

  container {

    container {

      table {
        title = "Overview"
        type  = "line"
        width = 3
        query = query.pod_overview
        args = {
          uid = self.input.pod_uid.value
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
        width = 3
        query = query.pod_labels
        args = {
          uid = self.input.pod_uid.value
        }
      }

      table {
        title = "Annotations"
        width = 6
        query = query.pod_annotations
        args = {
          uid = self.input.pod_uid.value
        }
      }
    }

    container {

      table {
        title = "Configuration"
        width = 6
        query = query.pod_configuration
        args = {
          uid = self.input.pod_uid.value
        }

        column "UID" {
          display = "none"
        }

        column "Node Name" {
          href = "${dashboard.node_detail.url_path}?input.node_uid={{.UID | @uri}}"
        }

      }

      table {
        title = "Containers"
        width = 6
        query = query.pod_container_basic_detail
        args = {
          uid = self.input.pod_uid.value
        }

        column "Container Value" {
          display = "none"
        }

        column "Name" {
          href = "${dashboard.container_detail.url_path}?input.container_name={{.'Container Value' | @uri}}"
        }
      }
    }
  }

  container {

    chart {
      title    = "Containers CPU Analysis"
      width    = 6
      query    = query.pod_container_cpu_detail
      grouping = "compare"
      type     = "column"
      args = {
        uid = self.input.pod_uid.value
      }

    }

    chart {
      title    = "Containers Memory Analysis"
      width    = 6
      query    = query.pod_container_memory_detail
      grouping = "compare"
      type     = "column"
      args = {
        uid = self.input.pod_uid.value
      }

    }

    table {
      title = "Init Containers"
      width = 6
      query = query.pod_init_containers_detail
      args = {
        uid = self.input.pod_uid.value
      }

    }

    table {
      title = "Volumes"
      width = 6
      query = query.pod_volumes
      args = {
        uid = self.input.pod_uid.value
      }

    }

    table {
      title = "Conditions"
      width = 6
      query = query.pod_conditions
      args = {
        uid = self.input.pod_uid.value
      }

    }

  }

}

# Input queries

query "pod_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'namespace', namespace,
        'context_name', context_name
      ) as tags
    from
      kubernetes_pod
    order by
      title;
  EOQ
}

# Card queries

query "pod_status" {
  sql = <<-EOQ
    select
      phase as "Phase"
    from
      kubernetes_pod
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "pod_container" {
  sql = <<-EOQ
    select
      count(c) as value,
      'Containers' as label
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "pod_default_namespace" {
  sql = <<-EOQ
    select
      'Namespace' as label,
      initcap(namespace) as value,
      case when namespace = 'default' then 'alert' else 'ok' end as type,
      n.uid as "UID"
    from
      kubernetes_pod as p,
      kubernetes_namespace as n
    where
      n.name = p.namespace
      and n.context_name = p.context_name
      and p.uid = $1;
  EOQ

  param "uid" {}
}

query "pod_container_host_network" {
  sql = <<-EOQ
    select
      'Host Network Access' as label,
      case when host_network then 'Enabled' else 'Disabled' end as value,
      case when host_network then 'alert' else 'ok' end as type
    from
      kubernetes_pod
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "pod_container_host_pid" {
  sql = <<-EOQ
    select
      'Host PID Sharing' as label,
      case when host_pid then 'Enabled' else 'Disabled' end as value,
      case when host_pid then 'alert' else 'ok' end as type
    from
      kubernetes_pod
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "pod_container_host_ipc" {
  sql = <<-EOQ
    select
      'Host IPC Sharing' as label,
      case when host_ipc then 'Enabled' else 'Disabled' end as value,
      case when host_ipc then 'alert' else 'ok' end as type
    from
      kubernetes_pod
    where
      uid = $1;
  EOQ

  param "uid" {}
}

# With queries

query "containers_for_pod" {
  sql = <<-EOQ
    select
      container ->> 'name' || p.name as name
    from
      kubernetes_pod as p,
      jsonb_array_elements(p.containers) as container
    where
      p.uid = $1;
  EOQ
}

query "init_containers_for_pod" {
  sql = <<-EOQ
    select
      container ->> 'name' || p.name as name
    from
      kubernetes_pod as p,
      jsonb_array_elements(p.init_containers) as container
    where
      p.uid = $1;
  EOQ
}

query "persistent_volumes_for_pod" {
  sql = <<-EOQ
    select
      distinct pv.uid as uid
    from
      kubernetes_pod as p,
      jsonb_array_elements(volumes) as v
      left join kubernetes_persistent_volume as pv
      on v -> 'persistentVolumeClaim' ->> 'claimName' = pv.claim_ref ->> 'name'
    where
      pv.uid is not null
      and v ->> 'name' in
      (select
        v ->> 'name'
      from kubernetes_pod,
      jsonb_array_elements(containers) as c,
      jsonb_array_elements(c -> 'volumeMounts') as v)
      and p.context_name = pv.context_name
      and p.uid = $1;
  EOQ
}

query "pod_persistent_volume_claims" {
  sql = <<-EOQ
    select
      distinct c.uid as uid
    from
      kubernetes_pod as p,
      jsonb_array_elements(volumes) as v
      left join kubernetes_persistent_volume_claim as c
      on v -> 'persistentVolumeClaim' ->> 'claimName' = c.name
    where
      c.uid is not null
      and v ->> 'name' in
      (select
        v ->> 'name'
      from kubernetes_pod,
      jsonb_array_elements(containers) as c,
      jsonb_array_elements(c -> 'volumeMounts') as v)
      and p.context_name = c.context_name
      and p.uid = $1;
  EOQ
}

query "configmaps_for_pod" {
  sql = <<-EOQ
    select
      c.uid as uid
    from
      kubernetes_pod as p,
      jsonb_array_elements(volumes) as v
      left join kubernetes_config_map as c
      on v -> 'configMap' ->> 'name' = c.name
    where
      c.uid is not null
      and p.context_name = c.context_name
      and v ->> 'name' in
      (select
        v ->> 'name'
      from kubernetes_pod,
      jsonb_array_elements(containers) as c,
      jsonb_array_elements(c -> 'volumeMounts') as v)
      and p.uid = $1;
  EOQ
}

query "secrets_for_pod" {
  sql = <<-EOQ
    select
      s.uid as uid
    from
      kubernetes_pod as p,
      jsonb_array_elements(volumes) as v
      left join kubernetes_secret as s
      on v -> 'secret' ->> 'secretName' = s.name
    where
      s.uid is not null
      and p.context_name = s.context_name
      and v ->> 'name' in
      (select
        v ->> 'name'
      from kubernetes_pod,
      jsonb_array_elements(containers) as c,
      jsonb_array_elements(c -> 'volumeMounts') as v)
      and p.uid = $1;
  EOQ
}

query "daemonsets_for_pod" {
  sql = <<-EOQ
    select
      d.uid as uid
    from
      kubernetes_daemonset as d,
      kubernetes_pod as p,
      jsonb_array_elements(p.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = d.uid
      and p.context_name = d.context_name
      and p.uid = $1;
  EOQ
}

query "jobs_for_pod" {
  sql = <<-EOQ
    select
      j.uid as uid
    from
      kubernetes_job as j,
      kubernetes_pod as p,
      jsonb_array_elements(p.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = j.uid
      and p.context_name = j.context_name
      and p.uid = $1;
  EOQ
}

query "replicasets_for_pod" {
  sql = <<-EOQ
    select
      pod_owner ->> 'uid' as uid
    from
      kubernetes_pod as p,
      jsonb_array_elements(p.owner_references) as pod_owner
    where
      pod_owner ->> 'kind' = 'ReplicaSet'
      and p.uid = $1;
  EOQ
}

query "deployments_for_pod" {
  sql = <<-EOQ
    select
     rs_owner ->> 'uid' as uid
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      pod.uid = $1
      and rs.context_name = pod.context_name
      and pod_owner ->> 'uid' = rs.uid;
  EOQ
}

query "statefulsets_for_pod" {
  sql = <<-EOQ
    select
      s.uid as uid
    from
      kubernetes_stateful_set as s,
      kubernetes_pod as p,
      jsonb_array_elements(p.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = s.uid
      and s.context_name = p.context_name
      and p.uid = $1;
  EOQ
}

query "service_accounts_for_pod" {
  sql = <<-EOQ
    select
      distinct s.uid as uid
    from
      kubernetes_service_account as s,
      kubernetes_pod as p
    where
      p.service_account_name = s.name
      and s.context_name = p.context_name
      and s.namespace in (select namespace from kubernetes_pod where uid = $1)
      and p.uid = $1;
  EOQ
}

# Other queries

query "pod_overview" {
  sql = <<-EOQ
    select
      p.name as "Name",
      p.uid as "UID",
      p.creation_timestamp as "Create Time",
      n.uid as "Namespace UID",
      n.name as "Namespace",
      p.context_name as "Context Name"
    from
      kubernetes_pod as p,
      kubernetes_namespace as n
    where
      n.name = p.namespace
      and n.context_name = p.context_name
      and p.uid = $1;
  EOQ

  param "uid" {}
}

query "pod_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_pod
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

query "pod_annotations" {
  sql = <<-EOQ
    with jsondata as (
   select
     annotations::json as annotation
   from
     kubernetes_pod
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

query "pod_conditions" {
  sql = <<-EOQ
    select
      c ->> 'lastTransitionTime' as "Last Transition Time",
      c ->> 'lastProbeTime' as "Last Probe Time",
      c ->> 'status' as "Status",
      c ->> 'type' as "Type"
    from
      kubernetes_pod,
      jsonb_array_elements(conditions) as c
    where
      uid = $1
    order by
      c ->> 'lastTransitionTime' desc;
  EOQ

  param "uid" {}
}

query "pod_configuration" {
  sql = <<-EOQ
    select
      p.node_name as "Node Name",
      n.uid as "UID",
      priority as "Priority",
      service_account_name as "Service Account Name",
      qos_class as "QoS",
      host_ip as "Host IP",
      pod_ip as "Pod IP"
    from
      kubernetes_pod as p
      left join kubernetes_node as n
      on p.node_name = n.name
      and p.context_name = n.context_name
    where
      p.uid = $1;
  EOQ

  param "uid" {}
}

query "pod_init_containers_detail" {
  sql = <<-EOQ
    select
      c ->> 'name' as "Name",
      c ->> 'image' as "Image",
      c ->> 'imagePullPolicy' as "Image Pull Policy",
      c ->> 'terminationMessagePath' as "Termination Message Path",
      c ->> 'terminationMessagePolicy' as "Termination Message Policy"
    from
      kubernetes_pod,
      jsonb_array_elements(init_containers) as c
    where
      uid = $1
    order by
      c ->> 'name';
  EOQ

  param "uid" {}
}

query "pod_volumes" {
  sql = <<-EOQ
    select
      v ->> 'name' as "Name",
      v -> 'configMap' ->> 'name' as "ConfigMap Name",
      v -> 'configMap' ->> 'defaultMode' as "ConfigMap Default Mode"
    from
      kubernetes_pod,
      jsonb_array_elements(volumes) as v
    where
      uid = $1
    order by
      v ->> 'name';
  EOQ

  param "uid" {}
}

query "pod_container_basic_detail" {
  sql = <<-EOQ
    select
      c ->> 'name' as "Name",
      c ->> 'image' as "Image",
      c -> 'securityContext' -> 'seccompProfile' ->> 'type' as "Seccomp Profile Type",
      concat(c ->> 'name',name) as "Container Value"
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      uid = $1
    order by
      c ->> 'name';
  EOQ

  param "uid" {}
}

query "pod_container_cpu_detail" {
  sql = <<-EOQ
    select
      c ->> 'name' as "Name",
      replace(c -> 'resources' -> 'limits' ->> 'cpu','m','') as "CPU Limit (m)",
      replace(c -> 'resources' -> 'requests' ->> 'cpu','m','') as "CPU Request (m)"
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      uid = $1
    order by
      c ->> 'name';
  EOQ

  param "uid" {}
}

query "pod_container_memory_detail" {
  sql = <<-EOQ
    select
      c ->> 'name' as "Name",
      replace(c -> 'resources' -> 'limits' ->> 'memory','Mi','') as "Memory Limit (Mi)",
      replace(c -> 'resources' -> 'requests' ->> 'memory','Mi','') as "Memory Request (Mi)"
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      uid = $1
    order by
      c ->> 'name';
  EOQ

  param "uid" {}
}
