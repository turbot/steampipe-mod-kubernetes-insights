edge "service_to_statefulset" {
  title = "statefulset"

  sql = <<-EOQ
     select
      s.uid as from_id,
      st.uid as to_id
    from
      kubernetes_stateful_set as st,
      kubernetes_service as s,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      (st.service_name = s.name or pod_owner ->> 'uid' = st.uid)
      and s.uid = any($1);
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
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      kubernetes_service as s
    where
      s.uid = any($1)
      and pod_owner ->> 'uid' = rs.uid
      and pod.selector_search = s.selector_query;
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
      kubernetes_service as s,
      kubernetes_pod as p
     where
      p.selector_search = s.selector_query
      and s.uid = any($1);
  EOQ

  param "service_uids" {}
}

