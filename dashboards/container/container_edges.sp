edge "container_to_node" {
  title = "node"

  sql = <<-EOQ
    select
      container ->> 'name' || pod.name as from_id,
      n.uid as to_id
    from
      kubernetes_node as n,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.containers) as container
    where
      n.name = pod.node_name
      and n.context_name = pod.context_name
      and container ->> 'name' || pod.name = any($1);
  EOQ

  param "container_names" {}
}

edge "container_to_container_volume" {
  title = "mounts"

  sql = <<-EOQ
    select
      c ->> 'name' || pod.name as from_id,
      v ->> 'name' as to_id
    from
      kubernetes_pod as pod,
      jsonb_array_elements(containers) as c,
      jsonb_array_elements(c -> 'volumeMounts') as v
    where
      concat(c ->> 'name',name) = any($1);
  EOQ

  param "container_names" {}
}

edge "container_volume_to_configmap" {
  title = "configmap"

  sql = <<-EOQ
    select
      v ->> 'name' as from_id,
      cm.uid as to_id,
      jsonb_build_object(
        'Mount Path', vm ->> 'mountPath'
      ) as properties
    from
      kubernetes_pod as p,
      jsonb_array_elements(containers) as c,
      jsonb_array_elements(c -> 'volumeMounts') as vm,
      jsonb_array_elements(volumes) as v
      left join kubernetes_config_map as cm
      on v -> 'configMap' ->> 'name' = cm.name
    where
      cm.uid is not null
      and p.context_name = cm.context_name
      and v ->> 'name' = vm ->> 'name'
      and p.uid = any($1);
  EOQ

  param "pod_uids" {}
}

edge "container_volume_to_secret" {
  title = "secret"

  sql = <<-EOQ
    select
      v ->> 'name' as from_id,
      s.uid as to_id,
      jsonb_build_object(
        'Mount Path', vm ->> 'mountPath'
      ) as properties
    from
      kubernetes_pod as p,
      jsonb_array_elements(containers) as c,
      jsonb_array_elements(c -> 'volumeMounts') as vm,
      jsonb_array_elements(volumes) as v
      left join kubernetes_secret as s
      on v -> 'secret' ->> 'secretName' = s.name
    where
      s.uid is not null
      and p.context_name = s.context_name
      and v ->> 'name' = vm ->> 'name'
      and p.uid = any($1);
  EOQ

  param "pod_uids" {}
}

edge "container_volume_to_persistent_volume_claim" {
  title = "persistent volume claim"

  sql = <<-EOQ
    select
      v ->> 'name' as from_id,
      vc.uid as to_id,
      jsonb_build_object(
        'Mount Path', vm ->> 'mountPath'
      ) as properties
    from
      kubernetes_pod as p,
      jsonb_array_elements(containers) as c,
      jsonb_array_elements(c -> 'volumeMounts') as vm,
      jsonb_array_elements(volumes) as v
      left join kubernetes_persistent_volume_claim as vc
      on v -> 'persistentVolumeClaim' ->> 'claimName' = vc.name
    where
      vc.uid is not null
      and p.context_name = vc.context_name
      and v ->> 'name' = vm ->> 'name'
      and p.uid = any($1);
  EOQ

  param "pod_uids" {}
}
