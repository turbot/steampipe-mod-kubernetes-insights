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

edge "namespace_to_job" {
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
      coalesce(
        a -> 'targetRef' ->> 'uid',
        n.uid
      ) as from_id,
      e.uid as to_id
    from
      kubernetes_namespace as n,
      kubernetes_endpoint as e
      left join jsonb_array_elements(subsets) as s on subsets is not null
      left join jsonb_array_elements(s -> 'addresses') as a on s -> 'addresses' is not null
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
