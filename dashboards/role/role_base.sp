graph "role_resource_structure" {
  param "role_uids" {}

  node "user_role" {
    category = category.user

    sql = <<-EOQ
        select
          s ->> 'name' as id,
          s ->> 'name' as title,
          jsonb_build_object(
          'Context Name', r.context_name
          ) as properties
        from
          kubernetes_role as r,
          kubernetes_role_binding as b,
          jsonb_array_elements(subjects) as s
        where
          b.role_name = r.name
          and b.context_name = r.context_name
          and s ->> 'kind' = 'User'
          and r.uid = any($1);
      EOQ

    args = [param.role_uids]
  }

  node "group_role" {
    category = category.group

    sql = <<-EOQ
        select
          s ->> 'name' as id,
          s ->> 'name' as title,
          jsonb_build_object(
          'Context Name', r.context_name
          ) as properties
        from
          kubernetes_role as r,
          kubernetes_role_binding as b,
          jsonb_array_elements(subjects) as s
        where
          b.role_name = r.name
          and b.context_name = r.context_name
          and s ->> 'kind' = 'Group'
          and r.uid = any($1);
      EOQ

    args = [param.role_uids]
  }

  edge "user_to_role_binding" {
    title = "role binding"

    sql = <<-EOQ
        select
          s ->> 'name' as from_id,
          b.uid as to_id
        from
          kubernetes_role as r,
          kubernetes_role_binding as b,
          jsonb_array_elements(subjects) as s
        where
          b.role_name = r.name
          and b.context_name = r.context_name
          and s ->> 'kind' = 'User'
          and r.uid = any($1);
      EOQ

    args = [param.role_uids]
  }

  edge "group_to_role_binding" {
    title = "role binding"

    sql = <<-EOQ
        select
          s ->> 'name' as from_id,
          b.uid as to_id
        from
          kubernetes_role as r,
          kubernetes_role_binding as b,
          jsonb_array_elements(subjects) as s
        where
          b.role_name = r.name
          and b.context_name = r.context_name
          and s ->> 'kind' = 'Group'
          and r.uid = any($1);
      EOQ

    args = [param.role_uids]
  }
}
