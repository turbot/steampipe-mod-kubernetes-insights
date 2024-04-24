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
      join
      unnest($1::text[]) as u on context_name = split_part(u, '/', 2) and uid = split_part(u, '/', 1);
  EOQ

  param "cluster_role_uids" {}
}
