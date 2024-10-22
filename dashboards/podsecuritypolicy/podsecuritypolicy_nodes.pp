node "pod_security_policy" {
  category = category.pod_security_policy

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Allow Privilege Escalation', allow_privilege_escalation,
        'Privileged', privileged,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_pod_security_policy
    where
      uid = any($1);
  EOQ

  param "pod_security_policy_uids" {}
}
