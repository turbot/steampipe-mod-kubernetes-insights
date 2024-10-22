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

node "init_container" {
  category = category.init_container

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
      jsonb_array_elements(init_containers) as container
    where
      concat(container ->> 'name',name) = any($1);
  EOQ

  param "init_container_names" {}
}

node "container_volume" {
  category = category.container_volume

  sql = <<-EOQ
    select
      v ->> 'name' as id,
      v ->> 'name' as title,
      jsonb_build_object(
        'Name', v ->> 'name',
        'Container Name', c ->> 'name',
        'Read Only', v ->> 'readOnly'
      ) as properties
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c,
      jsonb_array_elements(c -> 'volumeMounts') as v
    where
      concat(c ->> 'name',name) = any($1);
  EOQ

  param "container_names" {}
}

