dashboard "kubernetes_container_detail" {

  title         = "Kubernetes Container Detail"
  documentation = file("./dashboards/container/docs/container_detail.md")

  tags = merge(local.container_common_tags, {
    type = "Detail"
  })

  input "container_name" {
    title = "Select a container:"
    query = query.kubernetes_container_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kubernetes_container_privileged
      args = {
        name = self.input.container_name.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_container_allow_privilege_escalation
      args = {
        name = self.input.container_name.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_container_liveness_probe
      args = {
        name = self.input.container_name.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_container_readiness_probe
      args = {
        name = self.input.container_name.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_container_immutable_root_filesystem
      args = {
        name = self.input.container_name.value
      }
    }

  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      nodes = [
        node.kubernetes_container_node,
        node.kubernetes_container_from_pod_node
      ]

      edges = [
        edge.kubernetes_container_from_pod_edge
      ]

      args = {
        name = self.input.container_name.value
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
        query = query.kubernetes_container_overview
        args = {
          name = self.input.container_name.value
        }
      }

      table {
        title = "Volume Mounts"
        width = 6
        query = query.kubernetes_container_volume_mount
        args = {
          name = self.input.container_name.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Ports"
        query = query.kubernetes_container_ports
        args = {
          name = self.input.container_name.value
        }
      }

      chart {
        title = "Resources"
        query = query.kubernetes_container_resources
        type  = "column"
        args = {
          name = self.input.container_name.value
        }

      }

    }
  }

}

category "kubernetes_container_no_link" {}

node "kubernetes_container_node" {
  category = category.kubernetes_container_no_link

  sql = <<-EOQ
    select
      container ->> 'name' || p.name as id,
      container ->> 'name' as title,
      jsonb_build_object(
        'Name', container ->> 'name',
        'Image', container ->> 'image',
        'POD Name', p.name
      ) as properties
    from
      kubernetes_pod as p,
      jsonb_array_elements(containers) as container
    where
      concat(container ->> 'name',name) = $1;
  EOQ

  param "name" {}
}

node "kubernetes_container_from_pod_node" {
  category = category.kubernetes_pod

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Namespace', namespace,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as container
    where
      concat(container ->> 'name',name) = $1;
  EOQ

  param "name" {}
}

edge "kubernetes_container_from_pod_edge" {
  title = "container"

  sql = <<-EOQ
     select
      p.uid as from_id,
      container ->> 'name' || p.name as to_id
    from
      kubernetes_pod as p,
      jsonb_array_elements(p.containers) as container
    where
      concat(container ->> 'name',name) = $1;
  EOQ

  param "name" {}
}

query "kubernetes_container_input" {
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

query "kubernetes_container_privileged" {
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

query "kubernetes_container_allow_privilege_escalation" {
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

query "kubernetes_container_liveness_probe" {
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

query "kubernetes_container_readiness_probe" {
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

query "kubernetes_container_immutable_root_filesystem" {
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

query "kubernetes_container_overview" {
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

query "kubernetes_container_volume_mount" {
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

query "kubernetes_container_ports" {
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

query "kubernetes_container_resources" {
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
      concat(c ->> 'name',name) = $1
    union all
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

