dashboard "kubernetes_pod_detail" {

  title         = "Kubernetes Pod Detail"
  documentation = file("./dashboards/pod/docs/pod_detail.md")

  tags = merge(local.pod_common_tags, {
    type = "Detail"
  })

  input "pod_uid" {
    title = "Select a pod:"
    query = query.kubernetes_pod_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kubernetes_pod_status
      args = {
        uid = self.input.pod_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_pod_container
      args = {
        uid = self.input.pod_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_pod_default_namespace
      args = {
        uid = self.input.pod_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_pod_container_host_network
      args = {
        uid = self.input.pod_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_pod_container_host_pid
      args = {
        uid = self.input.pod_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_pod_container_host_ipc
      args = {
        uid = self.input.pod_uid.value
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
        query = query.kubernetes_pod_overview
        args = {
          uid = self.input.pod_uid.value
        }
      }

      table {
        title = "Labels"
        width = 6
        query = query.kubernetes_pod_labels
        args = {
          uid = self.input.pod_uid.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Configuration"
        query = query.kubernetes_pod_configuration
        args = {
          uid = self.input.pod_uid.value
        }

      }

      table {
      title = "Containers Basic Details"
      query = query.kubernetes_pod_container_basic_detail
      args = {
        uid = self.input.pod_uid.value
      }

      column "Container Value" {
      display = "none"
      }

      column "Name" {
      href = "${dashboard.kubernetes_container_detail.url_path}?input.container_name={{.'Container Value' | @uri}}"
      }
    }
    }
  }

  container {

    chart {
      title = "Containers CPU Analysis"
      width = 6
      query = query.kubernetes_pod_container_cpu_detail
      type  = "column"
      args = {
        uid = self.input.pod_uid.value
      }

    }

    chart {
      title = "Containers Memory Analysis"
      width = 6
      query = query.kubernetes_pod_container_memory_detail
      type  = "column"
      args = {
        uid = self.input.pod_uid.value
      }

    }

    table {
      title = "Volumes"
      width = 6
      query = query.kubernetes_pod_volumes
      args = {
        uid = self.input.pod_uid.value
      }

    }

    table {
      title = "Conditions"
      width = 6
      query = query.kubernetes_pod_conditions
      args = {
        uid = self.input.pod_uid.value
      }

    }

  }

}

query "kubernetes_pod_input" {
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

query "kubernetes_pod_container" {
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

query "kubernetes_pod_default_namespace" {
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

query "kubernetes_pod_container_host_network" {
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

query "kubernetes_pod_container_host_pid" {
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

query "kubernetes_pod_container_host_ipc" {
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

query "kubernetes_pod_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      creation_timestamp as "Create Time",
      context_name as "Context Name"
    from
      kubernetes_pod
    where
      uid = $1
  EOQ

  param "uid" {}
}

query "kubernetes_pod_labels" {
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
     json_each_text(label);
  EOQ

  param "uid" {}
}

query "kubernetes_pod_conditions" {
  sql = <<-EOQ
    select
      c ->> 'lastProbeTime' as "Last Probe Time",
      c ->> 'lastTransitionTime' as "Last Transition Time",
      c ->> 'status' as "Status",
      c ->> 'type' as "Type"
    from
      kubernetes_pod,
      jsonb_array_elements(conditions) as c
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_pod_configuration" {
  sql = <<-EOQ
    select
      node_name as "Node Name",
      priority as "Priority",
      service_account_name as "Service Account Name",
      qos_class as "QoS",
      host_ip as "Host IP",
      pod_ip as "Pod IP"
    from
      kubernetes_pod
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_pod_status" {
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

query "kubernetes_pod_volumes" {
  sql = <<-EOQ
    select
      v ->> 'name' as "Name",
      v -> 'configMap' ->> 'name' as "ConfigMap Name",
      v -> 'configMap' ->> 'defaultMode' as "ConfigMap Default Mode"
    from
      kubernetes_pod,
      jsonb_array_elements(volumes) as v
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_pod_container_basic_detail" {
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
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_pod_container_cpu_detail" {
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

query "kubernetes_pod_container_memory_detail" {
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