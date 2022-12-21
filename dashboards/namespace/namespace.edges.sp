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
