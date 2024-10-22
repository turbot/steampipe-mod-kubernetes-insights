edge "ingress_to_ingress_rule" {
  title = "rule"

  sql = <<-EOQ
     select
      i.uid as from_id,
      concat ((r ->> 'host'),(p ->> 'path')) as to_id
    from
      kubernetes_ingress as i,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements(r -> 'http' -> 'paths') as p
    where
      uid = any($1);
  EOQ

  param "ingress_uids" {}
}

edge "ingress_rule_to_service" {
  title = "service"

  sql = <<-EOQ
     select
      concat ((r ->> 'host'),(p ->> 'path')) as from_id,
      s.uid as to_id
    from
      kubernetes_service as s,
      kubernetes_ingress as i,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements(r -> 'http' -> 'paths') as p
    where
      s.name = p -> 'backend' -> 'service' ->> 'name'
      and s.context_name = i.context_name
      and i.uid = any($1);
  EOQ

  param "ingress_uids" {}
}

edge "ingress_load_balancer_to_ingress" {
  title = "ingress"

  sql = <<-EOQ
     select
      l::text as from_id,
      uid as to_id
    from
      kubernetes_ingress,
      jsonb_array_elements_text(load_balancer) as l
    where
      uid = any($1);
  EOQ

  param "ingress_uids" {}
}
