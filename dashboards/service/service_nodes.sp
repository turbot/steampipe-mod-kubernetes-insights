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
        'load_balancer_ip', load_balancer_ip,
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
