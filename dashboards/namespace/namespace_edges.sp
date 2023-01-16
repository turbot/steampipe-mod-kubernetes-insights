edge "namespace_to_daemonset" {
  title = "daemonset"

  sql = <<-EOQ
     select
      n.uid as from_id,
      d.uid as to_id
    from
      kubernetes_namespace as n,
      kubernetes_daemonset as d
    where
      n.name = d.namespace
      and n.uid = any($1);
  EOQ

  param "namespace_uids" {}
}

edge "namespace_to_role_binding" {
  title = "role binding"

  sql = <<-EOQ
     select
      n.uid as from_id,
      b.uid as to_id
    from
      kubernetes_namespace as n,
      kubernetes_role_binding as b
    where
      n.name = b.namespace
      and n.uid = any($1);
  EOQ

  param "namespace_uids" {}
}

edge "namespace_to_deployment" {
  title = "deployment"

  sql = <<-EOQ
     select
      n.uid as from_id,
      d.uid as to_id
    from
      kubernetes_namespace as n,
      kubernetes_deployment as d
    where
      n.name = d.namespace
      and n.uid = any($1);
  EOQ

  param "namespace_uids" {}
}

edge "namespace_to_ingress_load_balancer" {
  title = "load balancer"

  sql = <<-EOQ
     select
      n.uid as from_id,
      i.uid || l as to_id
    from
      kubernetes_namespace as n,
      kubernetes_ingress as i,
      jsonb_array_elements(load_balancer) as l
    where
      n.name = i.namespace
      and n.uid = any($1);
  EOQ

  param "namespace_uids" {}
}

edge "namespace_to_ingress_service" {
  title = "service"

  sql = <<-EOQ
    select
      n.uid as from_id,
      s.uid as to_id
    from
      kubernetes_namespace as n
      left join kubernetes_ingress as i
      on n.name = i.namespace
      left join kubernetes_service as s
      on n.name = s.namespace
    where
      i.uid is null
      and n.uid = any($1);
  EOQ

  param "namespace_uids" {}
}

edge "namespace_to_deployment_service" {
  title = "deployment"

  sql = <<-EOQ
    with service as (
      select
        s.uid,
        s.namespace
      from
        kubernetes_replicaset as rs,
        jsonb_array_elements(rs.owner_references) as rs_owner,
        kubernetes_pod as pod,
        jsonb_array_elements(pod.owner_references) as pod_owner,
        kubernetes_service as s
      where
        rs_owner ->> 'uid' = any($1)
        and pod_owner ->> 'uid' = rs.uid
        and pod.selector_search = s.selector_query
    )
    select
      coalesce(
        service.uid,
        n.uid
      ) as from_id,
      d.uid as to_id
      from
        kubernetes_namespace as n
        left join kubernetes_deployment as d
        on d.namespace = n.name
        left join service on
        service.namespace = n.name
    where
      d.uid = any($1);
  EOQ

  param "deployment_uids" {}
}

edge "namespace_to_cronjob" {
  title = "cronjob"

  sql = <<-EOQ
     select
      n.uid as from_id,
      c.uid as to_id
    from
      kubernetes_namespace as n,
      kubernetes_cronjob as c
    where
      n.name = c.namespace
      and n.uid = any($1);
  EOQ

  param "namespace_uids" {}
}

edge "namespace_to_cronjob_job" {
  title = "job"

  sql = <<-EOQ
     select
      coalesce(
        c.uid,
        n.uid
      ) as from_id,
      j.uid as to_id
    from
      kubernetes_namespace as n
      left join kubernetes_job as j
      on n.name = j.namespace
      left join kubernetes_cronjob as c
      on n.name = c.namespace
    where
      n.uid = any($1);
  EOQ

  param "namespace_uids" {}
}

edge "namespace_to_job" {
  title = "job"

  sql = <<-EOQ
     select
      n.uid as from_id,
      j.uid as to_id
    from
      kubernetes_namespace as n
      left join kubernetes_job as j
      on n.name = j.namespace
    where
      n.uid = any($1);
  EOQ

  param "namespace_uids" {}
}

edge "namespace_to_replicaset" {
  title = "replicaset"

  sql = <<-EOQ
     select
      n.uid as from_id,
      r.uid as to_id
    from
      kubernetes_namespace as n
      left join kubernetes_replicaset as r
      on n.name = r.namespace
    where
      n.uid = any($1);
  EOQ

  param "namespace_uids" {}
}

edge "namespace_to_role" {
  title = "role"

  sql = <<-EOQ
     select
      n.uid as from_id,
      r.uid as to_id
    from
      kubernetes_namespace as n,
      kubernetes_role as r
    where
      n.name = r.namespace
      and n.uid = any($1);
  EOQ

  param "namespace_uids" {}
}

edge "namespace_to_pod" {
  title = "pod"

  sql = <<-EOQ
     select
      n.uid as from_id,
      p.uid as to_id
    from
      kubernetes_pod as p,
      kubernetes_namespace as n
    where
      n.name = p.namespace
      and n.uid = any($1);
  EOQ

  param "namespace_uids" {}
}

edge "namespace_to_endpoint" {
  title = "endpoint"

  sql = <<-EOQ
     select
      n.uid from_id,
      e.uid as to_id
    from
      kubernetes_namespace as n,
      kubernetes_endpoint as e
    where
      n.name = e.namespace
      and n.uid = any($1);
  EOQ

  param "namespace_uids" {}
}

edge "namespace_to_service" {
  title = "service"

  sql = <<-EOQ
     select
      n.uid as from_id,
      s.uid as to_id
    from
      kubernetes_service as s
      left join kubernetes_namespace as n
      on s.namespace = n.name
      and n.uid = any($1);
  EOQ

  param "namespace_uids" {}
}

edge "namespace_to_statefulset" {
  title = "statefulset"

  sql = <<-EOQ
     select
      n.uid as from_id,
      s.uid as to_id
    from
      kubernetes_namespace as n,
      kubernetes_stateful_set as s
    where
      n.name = s.namespace
      and n.uid = any($1);
  EOQ

  param "namespace_uids" {}
}
