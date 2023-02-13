node "service" {
  category = category.service

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Type', type,
        'Cluster IP', cluster_ip,
        'Creation Timestamp', creation_timestamp,
        'Port', p ->> 'port',
        'Target Port', p ->> 'targetPort',
        'Protocol', p ->> 'protocol'
      ) as properties
    from
      kubernetes_service,
      jsonb_array_elements(ports) as p
    where
      uid = any($1);
  EOQ

  param "service_uids" {}
}

node "service_load_balancer" {
  category = category.service_load_balancer

  sql = <<-EOQ
    select
      l::text as id,
      l ->> 'ip' as title
    from
      kubernetes_service,
      jsonb_array_elements(load_balancer_ingress) as l
    where
      uid = any($1)
      and name not in
      (
      select
        p -> 'backend' -> 'service' ->> 'name'
      from
        kubernetes_ingress as i,
        jsonb_array_elements(rules) as r,
        jsonb_array_elements(r -> 'http' -> 'paths') as p
      );
  EOQ

  param "service_uids" {}
}
