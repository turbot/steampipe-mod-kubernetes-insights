graph "role_resource_structure" {
  param "role_uids" {}

  # node "rule" {
  #   category = category.rule

  #   sql = <<-EOQ
  #     select
  #       concat('rule', (r -> 'verbs')::text, (r -> 'apiGroups')::text, (r -> 'resources')::text, (r -> 'resourceNames')::text) as id,
  #       'rule' as title,
  #       jsonb_build_object(
  #       'Verbs', r -> 'verbs',
  #       'API Groups', r -> 'apiGroups',
  #       'Resources', r -> 'resources',
  #       'Resource Names', r -> 'resourceNames'
  #     ) as properties
  #     from
  #       kubernetes_role,
  #       jsonb_array_elements(rules) as r
  #     where
  #       uid = any($1);
  #     EOQ

  #   args = [param.role_uids]
  # }

  # with "rules" {
  #   sql = <<-EOQ
  #     select
  #       rules
  #     from
  #       kubernetes_role
  #     where
  #       uid = any($1);
  #   EOQ

  #   args = [param.role_uids]
  # }

  node "user" {
    category = category.user

    sql = <<-EOQ
        select
          s ->> 'name' as id,
          s ->> 'name' as title
        from
          kubernetes_role as r,
          kubernetes_role_binding as b,
          jsonb_array_elements(subjects) as s
        where
          b.role_name = r.name
          and s ->> 'kind' = 'User'
          and r.uid = any($1);
      EOQ

    args = [param.role_uids]
  }

  node "group" {
    category = category.group

    sql = <<-EOQ
        select
          s ->> 'name' as id,
          s ->> 'name' as title
        from
          kubernetes_role as r,
          kubernetes_role_binding as b,
          jsonb_array_elements(subjects) as s
        where
          b.role_name = r.name
          and s ->> 'kind' = 'Group'
          and r.uid = any($1);
      EOQ

    args = [param.role_uids]
  }

  # edge "role_to_rule" {
  #   title = "rule"

  #   sql = <<-EOQ
  #       select
  #       uid as from_id,
  #       concat('rule', (r -> 'verbs')::text, (r -> 'apiGroups')::text, (r -> 'resources')::text, (r -> 'resourceNames')::text) as to_id
  #     from
  #       kubernetes_role,
  #       jsonb_array_elements(rules) as r
  #     where
  #       uid = any($1);
  #     EOQ

  #   args = [param.role_uids]
  # }

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
          and s ->> 'kind' = 'Group'
          and r.uid = any($1);
      EOQ

    args = [param.role_uids]
  }
}
