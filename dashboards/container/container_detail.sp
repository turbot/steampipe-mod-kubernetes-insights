dashboard "container_detail" {

  title         = "Kubernetes Container Detail"
  documentation = file("./dashboards/container/docs/container_detail.md")

  tags = merge(local.container_common_tags, {
    type = "Detail"
  })

  input "container_name" {
    title = "Select a container:"
    query = query.container_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.container_privileged
      args = {
        name = self.input.container_name.value
      }
    }

    card {
      width = 2
      query = query.container_allow_privilege_escalation
      args = {
        name = self.input.container_name.value
      }
    }

    card {
      width = 2
      query = query.container_liveness_probe
      args = {
        name = self.input.container_name.value
      }
    }

    card {
      width = 2
      query = query.container_readiness_probe
      args = {
        name = self.input.container_name.value
      }
    }

    card {
      width = 2
      query = query.container_immutable_root_filesystem
      args = {
        name = self.input.container_name.value
      }
    }

  }

  with "pods" {
    query = query.container_pods
    args  = [self.input.container_name.value]
  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.container
        args = {
          container_names = [self.input.container_name.value]
        }
      }

      node {
        base = node.container_volume
        args = {
          container_names = [self.input.container_name.value]
        }
      }

      node {
        base = node.container_volume_mount_path
        args = {
          container_names = [self.input.container_name.value]
        }
      }

      node {
        base = node.pod
        args = {
          pod_uids = with.pods.rows[*].uid
        }
      }

      edge {
        base = edge.pod_to_container
        args = {
          pod_uids = with.pods.rows[*].uid
        }
      }

      edge {
        base = edge.container_to_container_volume
        args = {
          container_names = [self.input.container_name.value]
        }
      }

      edge {
        base = edge.container_volume_to_container_volume_mount_path
        args = {
          container_names = [self.input.container_name.value]
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
        query = query.container_overview
        args = {
          name = self.input.container_name.value
        }
      }

      table {
        title = "Volume Mounts"
        width = 6
        query = query.container_volume_mount
        args = {
          name = self.input.container_name.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Ports"
        query = query.container_ports
        args = {
          name = self.input.container_name.value
        }
      }

      chart {
        title = "CPU Resources"
        width = 6
        query = query.container_cpu_resources
        type  = "column"
        args = {
          name = self.input.container_name.value
        }
      }

      chart {
        title = "Memory Resources"
        width = 6
        query = query.container_memory_resources
        type  = "column"
        args = {
          name = self.input.container_name.value
        }

      }

    }
  }

}

# Input queries

query "container_input" {
  sql = <<-EOQ
  with containers as (
    select
      distinct c ->> 'name' as container_name,
      name,
      context_name
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    )
    select
      container_name as label,
      concat(container_name,name) as value,
      json_build_object(
        'name', name,
        'context_name', context_name
      ) as tags
    from
      containers
    order by
      container_name;
  EOQ
}

# Card queries


query "container_privileged" {
  sql = <<-EOQ
    select
      case when c -> 'securityContext' ->> 'privileged' = 'true' then 'Enabled' else 'Disabled' end as value,
      'Privileged' as label,
      case when c -> 'securityContext' ->> 'privileged' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      concat(c ->> 'name',name) = $1;
  EOQ

  param "name" {}
}

query "container_allow_privilege_escalation" {
  sql = <<-EOQ
    select
      case when c -> 'securityContext' ->> 'allowPrivilegeEscalation' = 'true' then 'Enabled' else 'Disabled' end as value,
      'Privilege Escalation' as label,
      case when c -> 'securityContext' ->> 'allowPrivilegeEscalation' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      concat(c ->> 'name',name) = $1;
  EOQ

  param "name" {}
}

query "container_liveness_probe" {
  sql = <<-EOQ
    select
      case when c -> 'livenessProbe' is null then 'Unavailable' else 'Available' end as value,
      'Liveness Probe' as label,
      case when c -> 'livenessProbe' is null then 'alert' else 'ok' end as type
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      concat(c ->> 'name',name) = $1;
  EOQ

  param "name" {}
}

query "container_readiness_probe" {
  sql = <<-EOQ
    select
      case when c -> 'readinessProbe' is null then 'Unavailable' else 'Available' end as value,
      'Readiness Probe' as label,
      case when c -> 'readinessProbe' is null then 'alert' else 'ok' end as type
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      concat(c ->> 'name',name) = $1;
  EOQ

  param "name" {}
}

query "container_immutable_root_filesystem" {
  sql = <<-EOQ
    select
      case when c -> 'securityContext' ->> 'readOnlyRootFilesystem' = 'true' then 'Used' else 'Unused' end as value,
      'Immutable Root Filesystem' as label,
      case when c -> 'securityContext' ->> 'readOnlyRootFilesystem' = 'true' then 'ok' else 'alert' end as type
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      concat(c ->> 'name',name) = $1;
  EOQ

  param "name" {}
}

# With queries

query "container_pods" {
  sql = <<-EOQ
    select
      uid
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      concat(c ->> 'name',name) = $1;
  EOQ
}

# Other queries

query "container_overview" {
  sql = <<-EOQ
    select
      c ->> 'name' as "Name",
      c ->> 'image' as "Image",
      name as "Pod Name",
      context_name as "Context Name"
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      concat(c ->> 'name',name) = $1;
  EOQ

  param "name" {}
}

query "container_volume_mount" {
  sql = <<-EOQ
    select
      v ->> 'name' as "Name",
      v ->> 'mountPath' as "Mount Path"
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c,
      jsonb_array_elements(c -> 'volumeMounts') as v
    where
      concat(c ->> 'name',name) = $1
    order by
      v ->> 'name';
  EOQ

  param "name" {}
}

query "container_ports" {
  sql = <<-EOQ
    select
      p ->> 'name' as "Name",
      p ->> 'protocol' as "Protocol",
      p ->> 'containerPort' as "Container Port"
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c,
      jsonb_array_elements(c -> 'ports') as p
    where
      concat(c ->> 'name',name) = $1
    order by
      p ->> 'name';
  EOQ

  param "name" {}
}

query "container_cpu_resources" {
  sql = <<-EOQ
    select
      'CPU Limit (m)' as label,
      REPLACE(c -> 'resources' -> 'limits' ->> 'cpu','m','') as value
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      concat(c ->> 'name',name) = $1
    union all
    select
      'CPU Request (m)' as label,
      REPLACE(c -> 'resources' -> 'requests' ->> 'cpu','m','') as value
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      concat(c ->> 'name',name) = $1;
  EOQ

  param "name" {}
}

query "container_memory_resources" {
  sql = <<-EOQ
    select
      'Memory Limit (Mi)' as label,
      REPLACE(c -> 'resources' -> 'limits' ->> 'memory','Mi','') as value
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      concat(c ->> 'name',name) = $1
    union all
    select
      'Memory Request (Mi)' as label,
      REPLACE(c -> 'resources' -> 'requests' ->> 'memory','Mi','') as value
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      concat(c ->> 'name',name) = $1;
  EOQ

  param "name" {}
}
