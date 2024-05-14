edge "service_to_statefulset" {
  title = "statefulset"

  sql = <<-EOQ
     select
      s.uid as from_id,
      st.uid as to_id
    from
      kubernetes_service as s
      join unnest($1::text[]) as u on s.uid = split_part(u, '/', 1)
      join kubernetes_stateful_set as st on st.context_name = split_part(u, '/', 2) and (st.service_name = s.name or st.uid = any(select value ->> 'uid' from jsonb_array_elements(pod.owner_references)))
      join kubernetes_pod as pod on pod.selector_search = s.selector_query
    where
      pod.context_name = split_part(u, '/', 2);
  EOQ

  param "service_uids" {}
}

edge "service_to_deployment" {
  title = "deployment"

  sql = <<-EOQ
     select
      s.uid as from_id,
      rs_owner ->> 'uid' as to_id
    from
      kubernetes_service as s
      join unnest($1::text[]) as u on s.uid = split_part(u, '/', 1)
      join kubernetes_replicaset as rs on rs.context_name = split_part(u, '/', 2)
      join jsonb_array_elements(rs.owner_references) as rs_owner on true
      join kubernetes_pod as pod on pod.selector_search = s.selector_query
      join jsonb_array_elements(pod.owner_references) as pod_owner on pod_owner ->> 'uid' = rs.uid
    where
      pod.context_name = split_part(u, '/', 2);
  EOQ

  param "service_uids" {}
}

edge "service_to_pod" {
  title = "pod"

  sql = <<-EOQ
     select
      s.uid as from_id,
      p.uid as to_id
    from
      kubernetes_service as s
      join
      kubernetes_pod as p on p.selector_search = s.selector_query
      join
      unnest($1::text[]) as u on p.context_name = split_part(u, '/', 2)
      and s.uid = split_part(u, '/', 1);
  EOQ

  param "service_uids" {}
}

edge "service_load_balancer_to_service" {
  title = "service"

  sql = <<-EOQ
     select
      l::text as from_id,
      uid as to_id
    from
      kubernetes_service,
      join
      jsonb_array_elements(load_balancer_ingress) as l on true
      join
      unnest($1::text[]) as u on context_name = split_part(u, '/', 2)
      and uid = split_part(u, '/', 1);
  EOQ

  param "service_uids" {}
}
