dashboard "kubernetes_cluster_detail" {

  title         = "Kubernetes Cluster Detail"
  documentation = file("./dashboards/cluster/docs/cluster_detail.md")

  tags = merge(local.cluster_common_tags, {
    type = "Detail"
  })

  input "cluster_context" {
    title = "Select a cluster:"
    query = query.kubernetes_cluster_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kubernetes_cluster_namespaces_count
      args = {
        context = self.input.cluster_context.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_cluster_node_count
      args = {
        context = self.input.cluster_context.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_cluster_persistent_volumes_count
      args = {
        context = self.input.cluster_context.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_cluster_pod_security_policy_count
      args = {
        context = self.input.cluster_context.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_cluster_role_binding_count
      args = {
        context = self.input.cluster_context.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_cluster_role_count
      args = {
        context = self.input.cluster_context.value
      }
    }

  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      nodes = [
        node.kubernetes_cluster_node,
        node.kubernetes_cluster_to_namespace_node,
        node.kubernetes_cluster_to_node_node,
        node.kubernetes_cluster_to_persistentvolume_node,
        node.kubernetes_cluster_to_psp_node,
        node.kubernetes_cluster_to_rolebinding_node,
        node.kubernetes_cluster_to_role_node
      ]

      edges = [
        edge.kubernetes_cluster_to_namespace_edge,
        edge.kubernetes_cluster_to_node_edge,
        edge.kubernetes_cluster_to_persistentvolume_edge,
        edge.kubernetes_cluster_to_psp_edge,
        edge.kubernetes_cluster_to_rolebinding_edge,
        edge.kubernetes_cluster_to_role_edge
      ]

      args = {
        context = self.input.cluster_context.value
      }
    }
  }

  container {

    table {
      title = "Namespaces"
      width = 6
      query = query.kubernetes_cluster_namespaces_table
      args = {
        context = self.input.cluster_context.value
      }

      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.kubernetes_namespace_detail.url_path}?input.namespace_uid={{.UID | @uri}}"
      }
    }

    table {
      title = "Nodes"
      width = 6
      query = query.kubernetes_cluster_nodes_table
      args = {
        context = self.input.cluster_context.value
      }

      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.kubernetes_node_detail.url_path}?input.node_uid={{.UID | @uri}}"
      }
    }

    table {
      title = "Persistent Volumes"
      width = 6
      query = query.kubernetes_cluster_persistent_volumes_table
      args = {
        context = self.input.cluster_context.value
      }
    }

    table {
      title = "Pod Security Policies"
      width = 6
      query = query.kubernetes_cluster_pod_security_policy_table
      args = {
        context = self.input.cluster_context.value
      }
    }

    table {
      title = "Role Bindings"
      width = 6
      query = query.kubernetes_cluster_role_binding_table
      args = {
        context = self.input.cluster_context.value
      }
    }

    table {
      title = "Roles"
      width = 6
      query = query.kubernetes_cluster_role_table
      args = {
        context = self.input.cluster_context.value
      }
    }
  }
}

category "kubernetes_cluster_no_link" {
  icon = local.kubernetes_cluster_icon
}

node "kubernetes_cluster_node" {
  category = category.kubernetes_cluster_no_link

  sql = <<-EOQ
    select
      context_name as id,
      context_name as title
    from
      kubernetes_namespace
    where
      context_name = $1;
  EOQ

  param "context" {}
}

node "kubernetes_cluster_to_namespace_node" {
  category = category.kubernetes_namespace

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Phase', phase,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_namespace
    where
      context_name = $1;
  EOQ

  param "context" {}
}

edge "kubernetes_cluster_to_namespace_edge" {
  title = "namespace"

  sql = <<-EOQ
    select
      context_name as from_id,
      uid as to_id
    from
      kubernetes_namespace
    where
      context_name = $1;
  EOQ

  param "context" {}
}

node "kubernetes_cluster_to_node_node" {
  category = category.kubernetes_node

  sql = <<-EOQ
    select
      uid as id,
      name as title,
      jsonb_build_object(
        'UID', uid,
        'POD CIDR', pod_cidr,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_node
    where
      context_name = $1;
  EOQ

  param "context" {}
}

edge "kubernetes_cluster_to_node_edge" {
  title = "node"

  sql = <<-EOQ
    select
      context_name as from_id,
      uid as to_id
    from
      kubernetes_node
    where
      context_name = $1;
  EOQ

  param "context" {}
}

node "kubernetes_cluster_to_persistentvolume_node" {
  category = category.kubernetes_persistentvolume

  sql = <<-EOQ
    select
      uid as id,
      name as title,
      jsonb_build_object(
        'UID', uid,
        'Storage Class', storage_class,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_persistent_volume
    where
      context_name = $1;
  EOQ

  param "context" {}
}

edge "kubernetes_cluster_to_persistentvolume_edge" {
  title = "persistentvolume"

  sql = <<-EOQ
    select
      context_name as from_id,
      uid as to_id
    from
      kubernetes_persistent_volume
    where
      context_name = $1;
  EOQ

  param "context" {}
}

node "kubernetes_cluster_to_psp_node" {
  category = category.kubernetes_psp

  sql = <<-EOQ
    select
      uid as id,
      name as title,
      jsonb_build_object(
        'UID', uid,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_pod_security_policy
    where
      context_name = $1;
  EOQ

  param "context" {}
}

edge "kubernetes_cluster_to_psp_edge" {
  title = "psp"

  sql = <<-EOQ
    select
      context_name as from_id,
      uid as to_id
    from
      kubernetes_pod_security_policy
    where
      context_name = $1;
  EOQ

  param "context" {}
}

node "kubernetes_cluster_to_rolebinding_node" {
  category = category.kubernetes_rolebinding

  sql = <<-EOQ
    select
      uid as id,
      name as title,
      jsonb_build_object(
        'UID', uid,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_role_binding
    where
      context_name = $1;
  EOQ

  param "context" {}
}

edge "kubernetes_cluster_to_rolebinding_edge" {
  title = "rolebinding"

  sql = <<-EOQ
    select
      context_name as from_id,
      uid as to_id
    from
      kubernetes_role_binding
    where
      context_name = $1;
  EOQ

  param "context" {}
}

node "kubernetes_cluster_to_role_node" {
  category = category.kubernetes_role

  sql = <<-EOQ
    select
      uid as id,
      name as title,
      jsonb_build_object(
        'UID', uid,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_role
    where
      context_name = $1;
  EOQ

  param "context" {}
}

edge "kubernetes_cluster_to_role_edge" {
  title = "role"

  sql = <<-EOQ
    select
      context_name as from_id,
      uid as to_id
    from
      kubernetes_role
    where
      context_name = $1;
  EOQ

  param "context" {}
}

query "kubernetes_cluster_input" {
  sql = <<-EOQ
    select
     distinct context_name as label,
     context_name as value
    from
      kubernetes_namespace
    order by
      context_name;
  EOQ
}

query "kubernetes_cluster_namespaces_count" {
  sql = <<-EOQ
    select
      'Namespaces' as label,
      count(*) as value
    from
      kubernetes_namespace
    where
      context_name = $1;
  EOQ

  param "context" {}
}

query "kubernetes_cluster_node_count" {
  sql = <<-EOQ
    select
      'Nodes' as label,
      count(*) as value
    from
      kubernetes_node
    where
      context_name = $1;
  EOQ

  param "context" {}
}

query "kubernetes_cluster_persistent_volumes_count" {
  sql = <<-EOQ
    select
      'Persistent Volumes' as label,
      count(*) as value
    from
      kubernetes_persistent_volume
    where
      context_name = $1;
  EOQ

  param "context" {}
}

query "kubernetes_cluster_pod_security_policy_count" {
  sql = <<-EOQ
    select
      'Pod Security Policies' as label,
      count(*) as value
    from
      kubernetes_pod_security_policy
    where
      context_name = $1;
  EOQ

  param "context" {}
}

query "kubernetes_cluster_role_binding_count" {
  sql = <<-EOQ
    select
      'Role Bindings' as label,
      count(*) as value
    from
      kubernetes_role_binding
    where
      context_name = $1;
  EOQ

  param "context" {}
}

query "kubernetes_cluster_role_count" {
  sql = <<-EOQ
    select
      'Roles' as label,
      count(*) as value
    from
      kubernetes_role
    where
      context_name = $1;
  EOQ

  param "context" {}
}

query "kubernetes_cluster_namespaces_table" {
  sql = <<-EOQ
    select
      name as "Name",
      phase as "Phase",
      creation_timestamp as "Create Time"
    from
      kubernetes_namespace
    where
      context_name = $1
    order by
      name;
  EOQ

  param "context" {}
}

query "kubernetes_cluster_nodes_table" {
  sql = <<-EOQ
    select
      name as "Name",
      pod_cidr as "Pod CIDR",
      creation_timestamp as "Create Time"
    from
      kubernetes_node
    where
      context_name = $1
    order by
      name;
  EOQ

  param "context" {}
}

query "kubernetes_cluster_persistent_volumes_table" {
  sql = <<-EOQ
    select
      name as "Name",
      storage_class as "Storage Class",
      volume_mode as "Volume Mode",
      phase as "Phase",
      creation_timestamp as "Create Time"
    from
      kubernetes_persistent_volume
    where
      context_name = $1
    order by
      name;
  EOQ

  param "context" {}
}

query "kubernetes_cluster_pod_security_policy_table" {
  sql = <<-EOQ
    select
      name as "Name",
      allow_privilege_escalation as "Allow Privilege Escalation",
      host_network as "Host Network",
      host_pid as "Host PID",
      host_ipc as "Host IPC",
      privileged as "Privileged",
      creation_timestamp as "Create Time"
    from
      kubernetes_pod_security_policy
    where
      context_name = $1
    order by
      name;
  EOQ

  param "context" {}
}

query "kubernetes_cluster_role_binding_table" {
  sql = <<-EOQ
    select
      name as "Name",
      namespace as "Namespace",
      role_name as "Role Name",
      role_kind as "Role Kind",
      creation_timestamp as "Create Time"
    from
      kubernetes_role_binding
    where
      context_name = $1
    order by
      name;
  EOQ

  param "context" {}
}

query "kubernetes_cluster_role_table" {
  sql = <<-EOQ
    select
      name as "Name",
      namespace as "Namespace",
      creation_timestamp as "Create Time"
    from
      kubernetes_role
    where
      context_name = $1
    order by
      name;
  EOQ

  param "context" {}
}

