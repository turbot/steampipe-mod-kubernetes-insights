edge "statefulset_to_service" {
  title = "service"

  sql = <<-EOQ
     select
      st.uid as from_id,
      s.uid as to_id
    from
      kubernetes_stateful_set as st,
      kubernetes_service as s
    where
      st.service_name = s.name
      and st.uid = any($1);
  EOQ

  param "statefulset_uids" {}
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

edge "statefulset_to_pod" {
  title = "pod"

  sql = <<-EOQ
     select
      pod_owner ->> 'uid' as from_id,
      p.uid as to_id
    from
      kubernetes_pod as p,
      jsonb_array_elements(p.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = any($1);
  EOQ

  param "statefulset_uids" {}
}
