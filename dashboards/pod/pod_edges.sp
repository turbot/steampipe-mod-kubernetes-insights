edge "pod_to_container" {
  title = "container"

  sql = <<-EOQ
     select
      p.uid as from_id,
      container ->> 'name' || p.name as to_id
    from
      kubernetes_pod as p,
      jsonb_array_elements(p.containers) as container
    where
      uid = any($1);
  EOQ

  param "pod_uids" {}
}

edge "pod_to_endpoint" {
  title = "endpoint"

  sql = <<-EOQ
     select
      p.uid as from_id,
      e.uid as to_id
    from
      kubernetes_pod as p,
      kubernetes_endpoint as e,
      jsonb_array_elements(subsets) as s,
      jsonb_array_elements(s -> 'addresses') as a
    where
      p.uid = a -> 'targetRef' ->> 'uid'
      and p.uid = any($1);
  EOQ

  param "pod_uids" {}
}

edge "pod_to_service" {
  title = "service"

  sql = <<-EOQ
     select
      p.uid as from_id,
      s.uid as to_id
    from
      kubernetes_service as s,
      kubernetes_pod as p
     where
      p.selector_search = s.selector_query
      and p.uid = any($1);
  EOQ

  param "pod_uids" {}
}
