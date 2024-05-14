edge "pod_to_container" {
  title = "container"

  sql = <<-EOQ
     select
      p.uid as from_id,
      container ->> 'name' || p.name as to_id
    from
      kubernetes_pod as p
      join jsonb_array_elements(p.containers) as container as true
      join
      unnest($1::text[]) as u on context_name = split_part(u, '/', 2)
      and uid = split_part(u, '/', 1);
  EOQ

  param "pod_uids" {}
}

edge "pod_to_configmap" {
  title = "configmap"

  sql = <<-EOQ
     select
      p.uid as from_id,
      c.uid as to_id
    from
      kubernetes_pod as p
      join unnest($1::text[]) as u on p.uid = split_part(u, '/', 1)
      join jsonb_array_elements(p.volumes) as v on true
      left join kubernetes_config_map as c on v -> 'configMap' ->> 'name' = c.name and c.context_name = split_part(u, '/', 2)
    where
      c.uid is not null;
  EOQ

  param "pod_uids" {}
}

edge "pod_to_service_account" {
  title = "runs as"

  sql = <<-EOQ
     select
      p.uid as from_id,
      s.uid as to_id
    from
      kubernetes_service_account as s
      join kubernetes_pod as p on p.service_account_name = s.name
      join
      unnest($1::text[]) as u on s.context_name = split_part(u, '/', 2)
      and p.uid = split_part(u, '/', 1);
  EOQ

  param "pod_uids" {}
}

edge "pod_to_persistent_volume_claim" {
  title = "persistent volume claim"

  sql = <<-EOQ
     select
      p.uid as from_id,
      c.uid as to_id
    from
      kubernetes_pod as p
      join unnest($1::text[]) as u on p.uid = split_part(u, '/', 1)
      join jsonb_array_elements(p.volumes) as v on true
      left join kubernetes_persistent_volume_claim as c on v -> 'persistentVolumeClaim' ->> 'claimName' = c.name and c.context_name = split_part(u, '/', 2)
    where
      c.uid is not null;
  EOQ

  param "pod_uids" {}
}


edge "pod_to_init_container" {
  title = "init container"

  sql = <<-EOQ
     select
      p.uid as from_id,
      container ->> 'name' || p.name as to_id
    from
      kubernetes_pod as p,
      join jsonb_array_elements(p.init_containers) as container as true
      join
      unnest($1::text[]) as u on context_name = split_part(u, '/', 2)
      and uid = split_part(u, '/', 1);
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
      kubernetes_pod as p
      join unnest($1::text[]) as u on p.uid = split_part(u, '/', 1)
      join kubernetes_endpoint as e on e.context_name = split_part(u, '/', 2)
      join jsonb_array_elements(e.subsets) as s on true
      join jsonb_array_elements(s -> 'addresses') as a on p.uid = a -> 'targetRef' ->> 'uid';
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
      kubernetes_service as s
      join kubernetes_pod as p on p.selector_search = s.selector_query
      join
      unnest($1::text[]) as u on s.context_name = split_part(u, '/', 2)
      and p.uid = split_part(u, '/', 1);
  EOQ

  param "pod_uids" {}
}
