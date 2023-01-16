edge "ingress_to_service" {
  title = "service"

  sql = <<-EOQ
     select
      i.uid as from_id,
      s.uid as to_id
    from
      kubernetes_service as s,
      kubernetes_ingress as i,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements(r -> 'http' -> 'paths') as p
    where
      s.name = p -> 'backend' ->> 'serviceName'
      and i.uid = any($1);
  EOQ

  param "ingress_uids" {}
}

edge "ingress_to_ingress_rule" {
  title = "rule"

  sql = <<-EOQ
     select
      i.uid as from_id,
      i.uid || (r ->> 'host') as to_id
    from
      kubernetes_ingress as i,
      jsonb_array_elements(rules) as r
    where
      uid = any($1);
  EOQ

  param "ingress_uids" {}
}

edge "ingress_rule_to_ingress_rule_path" {
  title = "path"

  sql = <<-EOQ
     select
      i.uid || (r ->> 'host') as from_id,
      i.uid || (r ->> 'host') || (p -> 'backend' ->> 'serviceName') as to_id
    from
      kubernetes_ingress as i,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements(r -> 'http' -> 'paths') as p
    where
      uid = any($1);
  EOQ

  param "ingress_uids" {}
}

edge "ingress_rule_path_to_service" {
  title = "service"

  sql = <<-EOQ
     select
      i.uid || (r ->> 'host') || (p -> 'backend' ->> 'serviceName') as from_id,
      s.uid as to_id
    from
      kubernetes_service as s,
      kubernetes_ingress as i,
      jsonb_array_elements(rules) as r,
      jsonb_array_elements(r -> 'http' -> 'paths') as p
    where
      s.name = p -> 'backend' ->> 'serviceName'
      and i.uid = any($1);
  EOQ

  param "ingress_uids" {}
}

edge "ingress_load_balancer_to_ingress" {
  title = "ingress"

  sql = <<-EOQ
     select
      uid || l as from_id,
      uid as to_id
    from
      kubernetes_ingress,
      jsonb_array_elements_text(load_balancer) as l
    where
      uid = any($1);
  EOQ

  param "ingress_uids" {}
}
