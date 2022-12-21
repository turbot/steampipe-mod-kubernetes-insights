node "cluster" {
  category = category.cluster

  sql = <<-EOQ
    select
      context_name as id,
      context_name as title,
      jsonb_build_object(
        'Context Name', context_name
      ) as properties
    from
      kubernetes_namespace
    where
      context_name = any($1);
  EOQ

  param "cluster_names" {}
}
