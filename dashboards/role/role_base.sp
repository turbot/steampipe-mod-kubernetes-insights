graph "role_resource_structure" {
  param "role_uids" {}

  node "user_role" {
    category = category.user

    sql = <<-EOQ
      select
        s ->> 'name' as id,
        s ->> 'name' as title,
        jsonb_build_object(
          'context name', r.context_name
        ) as properties
      from
        kubernetes_role as r
      join
        kubernetes_role_binding as b on b.role_name = r.name
      join
        jsonb_array_elements(b.subjects) as s on s ->> 'kind' = 'User'
      join
        unnest($1::text[]) as u on b.context_name = split_part(u, '/', 2)
        and r.uid = split_part(u, '/', 1);
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
          'context name', r.context_name
        ) as properties
      from
        kubernetes_role as r
      join
        kubernetes_role_binding as b on b.role_name = r.name
      join
        jsonb_array_elements(b.subjects) as s on s ->> 'kind' = 'Group'
      join
        unnest($1::text[]) as u on b.context_name = split_part(u, '/', 2)
        and r.uid = split_part(u, '/', 1);
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
        kubernetes_role as r
      join
        kubernetes_role_binding as b on b.role_name = r.name
      join
        jsonb_array_elements(b.subjects) as s on s ->> 'kind' = 'User'
      join
        unnest($1::text[]) as u on b.context_name = split_part(u, '/', 2)
        and r.uid = split_part(u, '/', 1);
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
        kubernetes_role as r
      join
        kubernetes_role_binding as b on b.role_name = r.name
      join
        jsonb_array_elements(b.subjects) as s on s ->> 'kind' = 'Group'
      join
        unnest($1::text[]) as u on b.context_name = split_part(u, '/', 2)
        and r.uid = split_part(u, '/', 1);
      EOQ

    args = [param.role_uids]
  }
}
