node "ingress" {
  category = category.ingress

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Ingress Class Name', ingress_class_name,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_ingress
    where
      uid = any($1);
  EOQ

  param "ingress_uids" {}
}

node "ingress_load_balancer" {
  category = category.ingress_load_balancer

  sql = <<-EOQ
    select
      l::text as id,
      l ->> 'ip' as title
    from
      kubernetes_ingress,
      jsonb_array_elements(load_balancer) as l
    where
      uid = any($1);
  EOQ

  param "ingress_uids" {}
}

node "ingress_rule" {
  category = category.ingress_rule

  sql = <<-EOQ
    select
      concat ((r ->> 'host'),(p ->> 'path')) as id,
      concat ((r ->> 'host'),(p ->> 'path')) as title,
      jsonb_build_object(
        'Host', r ->> 'host',
        'Path', p ->> 'path',
        'Path Type', p ->> 'pathType',
        'Service Port', p -> 'backend' -> 'service' -> 'port' ->> 'number'
      ) as properties
    from
      kubernetes_ingress as i,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements(r -> 'http' -> 'paths') as p
    where
      uid = any($1);
  EOQ

  param "ingress_uids" {}
}

