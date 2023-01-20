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
      uid || l as id,
      'Load Balancer' as title,
      jsonb_build_object(
        'IP', l ->> 'ip'
      ) as properties
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
      i.uid || (r ->> 'host') as id,
      'rule' as title,
      jsonb_build_object(
        'Host', r ->> 'host'
      ) as properties
    from
      kubernetes_ingress as i,
      jsonb_array_elements(rules) as r
    where
      uid = any($1);
  EOQ

  param "ingress_uids" {}
}

