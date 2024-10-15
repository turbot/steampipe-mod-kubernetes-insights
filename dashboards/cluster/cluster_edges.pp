edge "cluster_to_namespace" {
  title = "namespace"

  sql = <<-EOQ
    select
      context_name as from_id,
      uid as to_id
    from
      kubernetes_namespace
    where
      context_name = any($1);
  EOQ

  param "cluster_names" {}
}

edge "cluster_to_node" {
  title = "node"

  sql = <<-EOQ
    select
      context_name as from_id,
      uid as to_id
    from
      kubernetes_node
    where
      context_name = any($1);
  EOQ

  param "cluster_names" {}
}

edge "cluster_to_persistent_volume" {
  title = "persistent volume"

  sql = <<-EOQ
    select
      context_name as from_id,
      uid as to_id
    from
      kubernetes_persistent_volume
    where
      context_name = any($1);
  EOQ

  param "cluster_names" {}
}

edge "cluster_to_pod_security_policy" {
  title = "pod security policy"

  sql = <<-EOQ
    select
      context_name as from_id,
      uid as to_id
    from
      kubernetes_pod_security_policy
    where
      context_name = any($1);
  EOQ

  param "cluster_names" {}
}

edge "cluster_to_cluster_role_binding" {
  title = "cluster role binding"

  sql = <<-EOQ
    select
      context_name as from_id,
      uid as to_id
    from
      kubernetes_cluster_role_binding
    where
      context_name = any($1);
  EOQ

  param "cluster_names" {}
}

edge "cluster_to_cluster_role" {
  title = "cluster role"

  sql = <<-EOQ
    select
      context_name as from_id,
      uid as to_id
    from
      kubernetes_cluster_role
    where
      context_name = any($1);
  EOQ

  param "cluster_names" {}
}
