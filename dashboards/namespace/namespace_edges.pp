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
      and n.context_name = d.context_name
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
      and n.context_name = b.context_name
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
      and n.context_name = d.context_name
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
      and n.context_name = c.context_name
      and n.uid = any($1);
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
      and n.context_name = j.context_name
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
      and n.context_name = r.context_name
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
      and n.context_name = r.context_name
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
      and n.context_name = s.context_name
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
      and n.context_name = s.context_name
      and n.uid = any($1);
  EOQ

  param "namespace_uids" {}
}
