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

  with "containers" {
    query = query.pod_containers
    args  = [self.input.pod_uid.value]
  }

  with "init_containers" {
    query = query.pod_init_containers
    args  = [self.input.pod_uid.value]
  }

  with "persistent_volumes" {
    query = query.pod_persistent_volumes
    args  = [self.input.pod_uid.value]
  }

  with "configmaps" {
    query = query.pod_configmaps
    args  = [self.input.pod_uid.value]
  }

  # with "secrets" {
  #   query = query.pod_secrets
  #   args  = [self.input.pod_uid.value]
  # }

  with "persistent_volume_claims" {
    query = query.pod_persistent_volume_claims
    args  = [self.input.pod_uid.value]
  }

  with "nodes" {
    query = query.pod_nodes
    args  = [self.input.pod_uid.value]
  }

  with "daemonsets" {
    query = query.pod_daemonsets
    args  = [self.input.pod_uid.value]
  }

  with "jobs" {
    query = query.pod_jobs
    args  = [self.input.pod_uid.value]
  }

  with "replicasets" {
    query = query.pod_replicasets
    args  = [self.input.pod_uid.value]
  }

  with "statefulsets" {
    query = query.pod_statefulsets
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
        base = node.configmap
        args = {
          configmap_uids = with.configmaps.rows[*].uid
        }
      }

      # node {
      #   base = node.secret
      #   args = {
      #     secret_uids = with.secrets.rows[*].uid
      #   }
      # }

      node {
        base = node.container
        args = {
          container_names = with.containers.rows[*].name
        }
      }

      node {
        base = node.init_container
        args = {
          init_container_names = with.init_containers.rows[*].name
        }
      }

      node {
        base = node.container_volume
        args = {
          container_names = with.containers.rows[*].name
        }
      }

      node {
        base = node.container_volume_mount_path
        args = {
          container_names = with.containers.rows[*].name
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
          persistent_volume_uids = with.persistent_volumes.rows[*].uid
        }
      }

      node {
        base = node.node
        args = {
          node_uids = with.nodes.rows[*].uid
        }
      }

      node {
        base = node.daemonset
        args = {
          daemonset_uids = with.daemonsets.rows[*].uid
        }
      }

      node {
        base = node.job
        args = {
          job_uids = with.jobs.rows[*].uid
        }
      }

      node {
        base = node.replicaset
        args = {
          replicaset_uids = with.replicasets.rows[*].uid
        }
      }

      node {
        base = node.statefulset
        args = {
          statefulset_uids = with.statefulsets.rows[*].uid
        }
      }

      edge {
        base = edge.pod_to_configmap
        args = {
          pod_uids = [self.input.pod_uid.value]
        }
      }

      edge {
        base = edge.pod_to_persistent_volume_claim
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
        base = edge.node_to_pod
        args = {
          node_uids = with.nodes.rows[*].uid
        }
      }

      edge {
        base = edge.job_to_pod
        args = {
          job_uids = with.jobs.rows[*].uid
        }
      }

      edge {
        base = edge.replicaset_to_pod
        args = {
          replicaset_uids = with.replicasets.rows[*].uid
        }
      }

      edge {
        base = edge.daemonset_to_pod
        args = {
          daemonset_uids = with.daemonsets.rows[*].uid
        }
      }

      edge {
        base = edge.statefulset_to_pod
        args = {
          statefulset_uids = with.statefulsets.rows[*].uid
        }
      }

      edge {
        base = edge.container_to_container_volume
        args = {
          container_names = with.containers.rows[*].name
        }
      }

      edge {
        base = edge.container_volume_to_container_volume_mount_path
        args = {
          container_names = with.containers.rows[*].name
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
      case when namespace = 'default' then 'alert' else 'ok' end as type
    from
      kubernetes_pod
    where
      uid = $1;
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

query "pod_containers" {
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

query "pod_init_containers" {
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

query "pod_persistent_volumes" {
  sql = <<-EOQ
    select
      pv.uid as uid
    from
      kubernetes_pod as p,
      jsonb_array_elements(volumes) as v
      left join kubernetes_persistent_volume as pv
      on v -> 'persistentVolumeClaim' ->> 'claimName' = pv.claim_ref ->> 'name'
    where
      pv.uid is not null
      and p.uid = $1;
  EOQ
}

query "pod_persistent_volume_claims" {
  sql = <<-EOQ
    select
      c.uid as uid
    from
      kubernetes_pod as p,
      jsonb_array_elements(volumes) as v
      left join kubernetes_persistent_volume_claim as c
      on v -> 'persistentVolumeClaim' ->> 'claimName' = c.name
    where
      c.uid is not null
      and p.uid = $1;
  EOQ
}

query "pod_configmaps" {
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
      and p.uid = $1;
  EOQ
}

query "pod_secrets" {
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
      and p.uid = $1;
  EOQ
}

query "pod_nodes" {
  sql = <<-EOQ
     select
      n.uid as uid
    from
      kubernetes_pod as p,
      kubernetes_node as n
    where
      n.name = p.node_name
      and p.uid = $1;
  EOQ
}

query "pod_daemonsets" {
  sql = <<-EOQ
    select
      d.uid as uid
    from
      kubernetes_daemonset as d,
      kubernetes_pod as p,
      jsonb_array_elements(p.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = d.uid
      and p.uid = $1;
  EOQ
}

query "pod_jobs" {
  sql = <<-EOQ
    select
      j.uid as uid
    from
      kubernetes_job as j,
      kubernetes_pod as p,
      jsonb_array_elements(p.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = j.uid
      and p.uid = $1;
  EOQ
}

query "pod_replicasets" {
  sql = <<-EOQ
    select
      r.uid as uid
    from
      kubernetes_replicaset as r,
      kubernetes_pod as p,
      jsonb_array_elements(p.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = r.uid
      and p.uid = $1;
  EOQ
}

query "pod_statefulsets" {
  sql = <<-EOQ
    select
      s.uid as uid
    from
      kubernetes_stateful_set as s,
      kubernetes_pod as p,
      jsonb_array_elements(p.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = s.uid
      and p.uid = $1;
  EOQ
}

# Other queries

query "pod_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      creation_timestamp as "Create Time",
      context_name as "Context Name"
    from
      kubernetes_pod
    where
      uid = $1;
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
      left join kubernetes_node as n on p.node_name = n.name
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
      REPLACE(c -> 'resources' -> 'limits' ->> 'cpu','m','') as "CPU Limit (m)",
      REPLACE(c -> 'resources' -> 'requests' ->> 'cpu','m','') as "CPU Request (m)"
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
      REPLACE(c -> 'resources' -> 'limits' ->> 'memory','Mi','') as "Memory Limit (Mi)",
      REPLACE(c -> 'resources' -> 'requests' ->> 'memory','Mi','') as "Memory Request (Mi)"
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
