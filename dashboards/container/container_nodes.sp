node "container" {
  category = category.container

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
      concat(container ->> 'name',name) = any($1);
  EOQ

  param "container_names" {}
}
