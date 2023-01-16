node "role" {
  category = category.role

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Creation Timestamp', creation_timestamp,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_role
    where
      uid = any($1);
  EOQ

  param "role_uids" {}
}

node "cluster_role" {
  category = category.cluster_role

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Creation Timestamp', creation_timestamp,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_cluster_role
    where
      uid = any($1);
  EOQ

  param "cluster_role_uids" {}
}

node "service_account" {
  category = category.service_account

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Automount Service Account Token', automount_service_account_token,
        'Creation Timestamp', creation_timestamp,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_service_account
    where
      uid = any($1);
  EOQ

  param "service_account_uids" {}
}

node "user" {
  category = category.user

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Automount Service Account Token', automount_service_account_token,
        'Creation Timestamp', creation_timestamp,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_service_account
    where
      uid = any($1);
  EOQ

  param "service_account_uids" {}
}