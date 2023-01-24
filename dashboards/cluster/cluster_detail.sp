dashboard "cluster_detail" {

  title         = "Kubernetes Cluster Detail"
  documentation = file("./dashboards/cluster/docs/cluster_detail.md")

  tags = merge(local.cluster_common_tags, {
    type = "Detail"
  })

  input "cluster_context" {
    title = "Select a cluster:"
    query = query.cluster_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.cluster_namespaces_count
      args = {
        context = self.input.cluster_context.value
      }
    }

    card {
      width = 2
      query = query.cluster_node_count
      args = {
        context = self.input.cluster_context.value
      }
    }

    card {
      width = 2
      query = query.cluster_persistent_volumes_count
      args = {
        context = self.input.cluster_context.value
      }
    }

    card {
      width = 2
      query = query.cluster_pod_security_policy_count
      args = {
        context = self.input.cluster_context.value
      }
    }

    card {
      width = 2
      query = query.cluster_role_binding_count
      args = {
        context = self.input.cluster_context.value
      }
    }

    card {
      width = 2
      query = query.cluster_role_count
      args = {
        context = self.input.cluster_context.value
      }
    }

  }

  with "namespaces_for_cluster" {
    query = query.namespaces_for_cluster
    args  = [self.input.cluster_context.value]
  }

  with "nodes_for_cluster" {
    query = query.nodes_for_cluster
    args  = [self.input.cluster_context.value]
  }

  with "persistent_volumes_for_cluster" {
    query = query.persistent_volumes_for_cluster
    args  = [self.input.cluster_context.value]
  }

  with "pod_security_policies_for_cluster" {
    query = query.pod_security_policies_for_cluster
    args  = [self.input.cluster_context.value]
  }

  with "cluster_role_bindings_for_cluster" {
    query = query.cluster_role_bindings_for_cluster
    args  = [self.input.cluster_context.value]
  }

  with "cluster_roles_for_cluster" {
    query = query.cluster_roles_for_cluster
    args  = [self.input.cluster_context.value]
  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.cluster
        args = {
          cluster_names = [self.input.cluster_context.value]
        }
      }

      node {
        base = node.namespace
        args = {
          namespace_uids = with.namespaces_for_cluster.rows[*].uid
        }
      }

      node {
        base = node.node
        args = {
          node_uids = with.nodes_for_cluster.rows[*].uid
        }
      }

      node {
        base = node.persistent_volume
        args = {
          persistent_volume_uids = with.persistent_volumes_for_cluster.rows[*].uid
        }
      }

      node {
        base = node.pod_security_policy
        args = {
          pod_security_policy_uids = with.pod_security_policies_for_cluster.rows[*].uid
        }
      }

      node {
        base = node.cluster_role
        args = {
          cluster_role_uids = with.cluster_roles_for_cluster.rows[*].uid
        }
      }

      node {
        base = node.cluster_role_binding
        args = {
          cluster_role_binding_uids = with.cluster_role_bindings_for_cluster.rows[*].uid
        }
      }

      edge {
        base = edge.cluster_to_namespace
        args = {
          cluster_names = [self.input.cluster_context.value]
        }
      }

      edge {
        base = edge.cluster_to_node
        args = {
          cluster_names = [self.input.cluster_context.value]
        }
      }

      edge {
        base = edge.cluster_to_persistent_volume
        args = {
          cluster_names = [self.input.cluster_context.value]
        }
      }

      edge {
        base = edge.cluster_to_pod_security_policy
        args = {
          cluster_names = [self.input.cluster_context.value]
        }
      }

      edge {
        base = edge.cluster_to_cluster_role_binding
        args = {
          cluster_names = [self.input.cluster_context.value]
        }
      }

      edge {
        base = edge.cluster_to_cluster_role
        args = {
          cluster_names = [self.input.cluster_context.value]
        }
      }
    }
  }

  container {

    table {
      title = "Namespaces"
      width = 6
      query = query.cluster_namespaces_table
      args = {
        context = self.input.cluster_context.value
      }

      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "/kubernetes_insights.dashboard.namespace_detail?input.namespace_uid={{.'UID' | @uri}}"
      }
    }

    table {
      title = "Nodes"
      width = 6
      query = query.cluster_nodes_table
      args = {
        context = self.input.cluster_context.value
      }

      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.node_detail.url_path}?input.node_uid={{.'UID' | @uri}}"
      }
    }

    table {
      title = "Persistent Volumes"
      width = 6
      query = query.cluster_persistent_volumes_table
      args = {
        context = self.input.cluster_context.value
      }
    }

    table {
      title = "Pod Security Policies"
      width = 6
      query = query.cluster_pod_security_policy_table
      args = {
        context = self.input.cluster_context.value
      }
    }

    table {
      title = "Cluster Role Bindings"
      width = 6
      query = query.cluster_role_binding_table
      args = {
        context = self.input.cluster_context.value
      }
    }

    table {
      title = "Cluster Roles"
      width = 6
      query = query.cluster_role_table
      args = {
        context = self.input.cluster_context.value
      }

      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.cluster_role_detail.url_path}?input.cluster_role_uid={{.'UID' | @uri}}"
      }
    }
  }
}

# Input queries

query "cluster_input" {
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

# Card queries

query "cluster_namespaces_count" {
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

query "cluster_node_count" {
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

query "cluster_persistent_volumes_count" {
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

query "cluster_pod_security_policy_count" {
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

query "cluster_role_binding_count" {
  sql = <<-EOQ
    select
      'Cluster Role Bindings' as label,
      count(*) as value
    from
      kubernetes_cluster_role_binding
    where
      context_name = $1;
  EOQ

  param "context" {}
}

query "cluster_role_count" {
  sql = <<-EOQ
    select
      'Cluster Roles' as label,
      count(*) as value
    from
      kubernetes_cluster_role
    where
      context_name = $1;
  EOQ

  param "context" {}
}

# With queries

query "namespaces_for_cluster" {
  sql = <<-EOQ
    select
      uid
    from
      kubernetes_namespace
    where
      context_name = $1;
  EOQ
}

query "nodes_for_cluster" {
  sql = <<-EOQ
    select
      uid
    from
      kubernetes_node
    where
      context_name = $1;
  EOQ
}

query "persistent_volumes_for_cluster" {
  sql = <<-EOQ
    select
      uid
    from
      kubernetes_persistent_volume
    where
      context_name = $1;
  EOQ
}

query "pod_security_policies_for_cluster" {
  sql = <<-EOQ
    select
      uid
    from
      kubernetes_pod_security_policy
    where
      context_name = $1;
  EOQ
}

query "cluster_role_bindings_for_cluster" {
  sql = <<-EOQ
    select
      uid
    from
      kubernetes_cluster_role_binding
    where
      context_name = $1;
  EOQ
}

query "cluster_roles_for_cluster" {
  sql = <<-EOQ
    select
      uid
    from
      kubernetes_cluster_role
    where
      context_name = $1;
  EOQ
}

# Other queries

query "cluster_namespaces_table" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
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

query "cluster_nodes_table" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
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

query "cluster_persistent_volumes_table" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
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

query "cluster_pod_security_policy_table" {
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

query "cluster_role_binding_table" {
  sql = <<-EOQ
    select
      name as "Name",
      role_name as "Role Name",
      role_kind as "Role Kind",
      creation_timestamp as "Create Time"
    from
      kubernetes_cluster_role_binding
    where
      context_name = $1
    order by
      name;
  EOQ

  param "context" {}
}

query "cluster_role_table" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      creation_timestamp as "Create Time"
    from
      kubernetes_cluster_role
    where
      context_name = $1
    order by
      name;
  EOQ

  param "context" {}
}

