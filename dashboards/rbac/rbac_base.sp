graph "rbac_resource_structure" {
  param "rbac_role_uids" {}
  param "cluster_role_uids" {}
  param "role_uids" {}
  param "service_account_uids" {}
  param "role_binding_uids" {}
  param "cluster_role_binding_uids" {}
  param "rbac_verbs" {}
  param "rbac_resources" {}

  node {
    base = node.rbac_rule_verb_and_resource
    args = [param.rbac_role_uids, param.rbac_verbs, param.rbac_resources]
  }

  node {
    base = node.rbac_rule_resource_name
    args = [param.rbac_role_uids, param.rbac_verbs, param.rbac_resources]
  }

  edge {
    base = edge.rbac_rule_to_verb_and_resource
    args = [param.rbac_role_uids, param.rbac_verbs, param.rbac_resources]
  }

  edge {
    base = edge.rbac_rule_verb_and_resource_to_resource_name
    args = [param.rbac_role_uids, param.rbac_verbs, param.rbac_resources]
  }

  edge {
    base = edge.service_account_to_cluster_role_binding
    args = [param.service_account_uids]
  }

  edge {
    base = edge.service_account_to_role_binding
    args = [param.service_account_uids]
  }

  edge {
    base = edge.cluster_role_binding_to_cluster_role
    args = [param.cluster_role_uids]
  }

  edge {
    base = edge.role_binding_to_role
    args = [param.role_uids]
  }

  node {
    base = node.cluster_role_binding
    args = [param.cluster_role_binding_uids]
  }

  node {
    base = node.cluster_role
    args = [param.cluster_role_uids]
  }

  node {
    base = node.role
    args = [param.role_uids]
  }

  node {
    base = node.service_account
    args = [param.service_account_uids]
  }

  node {
    base = node.role_binding
    args = [param.role_binding_uids]
  }

  node "user_rbac" {
    category = category.user

    sql = <<-EOQ
        select
          s ->> 'name' as id,
          s ->> 'name' as title,
          jsonb_build_object(
          'Context Name', r.context_name
          ) as properties
        from
          kubernetes_cluster_role as r,
          kubernetes_cluster_role_binding as b,
          jsonb_array_elements(subjects) as s
        where
          b.role_name = r.name
          and b.context_name = r.context_name
          and s ->> 'kind' = 'User'
          and r.uid = any($1)
        union
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

    args = [param.rbac_role_uids]
  }

  node "group_rbac" {
    category = category.group

    sql = <<-EOQ
        select
          s ->> 'name' as id,
          s ->> 'name' as title,
          jsonb_build_object(
          'Context Name', r.context_name
          ) as properties
        from
          kubernetes_cluster_role as r,
          kubernetes_cluster_role_binding as b,
          jsonb_array_elements(subjects) as s
        where
          b.role_name = r.name
          and b.context_name = r.context_name
          and s ->> 'kind' = 'Group'
          and r.uid = any($1)
        union
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

    args = [param.rbac_role_uids]
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

    args = [param.rbac_role_uids]
  }

  edge "user_to_cluster_role_binding" {
    title = "cluster role binding"

    sql = <<-EOQ
        select
          s ->> 'name' as from_id,
          b.uid as to_id
        from
          kubernetes_cluster_role as r,
          kubernetes_cluster_role_binding as b,
          jsonb_array_elements(subjects) as s
        where
          b.role_name = r.name
          and b.context_name = r.context_name
          and s ->> 'kind' = 'User'
          and r.uid = any($1);
      EOQ

    args = [param.rbac_role_uids]
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

    args = [param.rbac_role_uids]
  }

  edge "group_to_cluster_role_binding" {
    title = "cluster role binding"

    sql = <<-EOQ
        select
          s ->> 'name' as from_id,
          b.uid as to_id
        from
          kubernetes_cluster_role as r,
          kubernetes_cluster_role_binding as b,
          jsonb_array_elements(subjects) as s
        where
          b.role_name = r.name
          and b.context_name = r.context_name
          and s ->> 'kind' = 'Group'
          and r.uid = any($1);
      EOQ

    args = [param.rbac_role_uids]
  }
}
