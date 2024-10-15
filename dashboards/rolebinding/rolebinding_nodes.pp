node "role_binding" {
  category = category.role_binding

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Role Kind', role_kind,
        'Creation Timestamp', creation_timestamp,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_role_binding
    where
      uid = any($1);
  EOQ

  param "role_binding_uids" {}
}

node "cluster_role_binding" {
  category = category.cluster_role_binding

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Role Kind', role_kind,
        'Creation Timestamp', creation_timestamp,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_cluster_role_binding
    where
      uid = any($1);
  EOQ

  param "cluster_role_binding_uids" {}
}

