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

edge "pod_to_configmap" {
  title = "configmap"

  sql = <<-EOQ
     select
      p.uid as from_id,
      c.uid as to_id
    from
      kubernetes_pod as p,
      jsonb_array_elements(volumes) as v
      left join kubernetes_config_map as c
      on v -> 'configMap' ->> 'name' = c.name
    where
      c.uid is not null
      and c.context_name = p.context_name
      and p.uid = any($1);
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
      kubernetes_service_account as s,
      kubernetes_pod as p
    where
      p.service_account_name = s.name
      and s.context_name = p.context_name
      and p.uid = any($1);
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
      kubernetes_pod as p,
      jsonb_array_elements(volumes) as v
      left join kubernetes_persistent_volume_claim as c
      on v -> 'persistentVolumeClaim' ->> 'claimName' = c.name
    where
      c.context_name = p.context_name
      and p.uid = any($1);
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
      jsonb_array_elements(p.init_containers) as container
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
      and e.context_name = p.context_name
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
      and s.context_name = p.context_name
      and p.uid = any($1);
  EOQ

  param "pod_uids" {}
}
