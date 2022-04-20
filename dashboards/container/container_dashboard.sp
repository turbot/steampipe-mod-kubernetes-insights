dashboard "kubernetes_container_dashboard" {

  title         = "Kubernetes Container Dashboard"
  documentation = file("./dashboards/container/docs/container_dashboard.md")

  tags = merge(local.container_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.kubernetes_container_count
      width = 2
    }

    card {
      query = query.kubernetes_container_privileged_count
      width = 2
    }

    card {
      query = query.kubernetes_container_allow_privilege_escalation_count
      width = 2
    }

    card {
      query = query.kubernetes_container_liveness_probe_count
      width = 2
    }

    card {
      query = query.kubernetes_container_readiness_probe_count
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Privileged Status"
      query = query.kubernetes_container_privileged_status
      type  = "donut"
      width = 3

      series "count" {
        point "privileged" {
          color = "alert"
        }
        point "underprivileged" {
          color = "ok"
        }
      }
    }

    chart {
      title = "Privilege Escalation Status"
      query = query.kubernetes_container_allow_privilege_escalation_status
      type  = "donut"
      width = 3

      series "count" {
        point "allowed" {
          color = "alert"
        }
        point "denied" {
          color = "ok"
        }
      }
    }

    chart {
      title = "Liveness Probe Status"
      query = query.kubernetes_container_liveness_probe_status
      type  = "donut"
      width = 3

      series "count" {
        point "unavailable" {
          color = "alert"
        }
        point "available" {
          color = "ok"
        }
      }
    }

    chart {
      title = "Readiness Probe Status"
      query = query.kubernetes_container_readiness_probe_status
      type  = "donut"
      width = 3

      series "count" {
        point "unavailable" {
          color = "alert"
        }
        point "available" {
          color = "ok"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Containers by Cluster"
      query = query.kubernetes_container_by_context_name
      type  = "column"
      width = 4
    }

    chart {
      title = "Containers by Namespace"
      query = query.kubernetes_container_by_namespace
      type  = "column"
      width = 4
    }

  }

}

# Card Queries

query "kubernetes_container_count" {
  sql = <<-EOQ
    select
      count(c) as "Containers"
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c;
  EOQ
}

query "kubernetes_container_privileged_count" {
  sql = <<-EOQ
    select
      count(c ->> 'name') as value,
      'Privileged' as label,
      case count(c ->> 'name') when 0 then 'ok' else 'alert' end as type
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      c -> 'securityContext' ->> 'privileged' = 'true';
  EOQ
}

query "kubernetes_container_allow_privilege_escalation_count" {
  sql = <<-EOQ
    select
      count(c ->> 'name') as value,
      'Allow Privilege Escalation' as label,
      case count(c ->> 'name') when 0 then 'ok' else 'alert' end as type
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      c -> 'securityContext' ->> 'allowPrivilegeEscalation' = 'true';
  EOQ
}

query "kubernetes_container_liveness_probe_count" {
  sql = <<-EOQ
    select
      count(c ->> 'name') as value,
      'Liveness Probe Unavailable' as label,
      case count(c ->> 'name') when 0 then 'ok' else 'alert' end as type
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      c -> 'livenessProbe' is null;
  EOQ
}

query "kubernetes_container_readiness_probe_count" {
  sql = <<-EOQ
    select
      count(c ->> 'name') as value,
      'Readiness Probe Unavailable' as label,
      case count(c ->> 'name') when 0 then 'ok' else 'alert' end as type
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      c -> 'readinessProbe' is null;
  EOQ
}

# Assessment Queries

query "kubernetes_container_privileged_status" {
  sql = <<-EOQ
    select
      case when c -> 'securityContext' ->> 'privileged' = 'true' then 'privileged' else 'underprivileged' end as status,
      count(c)
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    group by
      status;
  EOQ
}

query "kubernetes_container_allow_privilege_escalation_status" {
  sql = <<-EOQ
    select
      case when c -> 'securityContext' ->> 'allowPrivilegeEscalation' = 'true' then 'allowed' else 'denied' end as status,
      count(c)
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    group by
      status;
  EOQ
}

query "kubernetes_container_liveness_probe_status" {
  sql = <<-EOQ
    select
      case when c -> 'livenessProbe' is null then 'unavailable' else 'available' end as status,
      count(c)
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    group by
      status;
  EOQ
}

query "kubernetes_container_readiness_probe_status" {
  sql = <<-EOQ
    select
      case when c -> 'readinessProbe' is null then 'unavailable' else 'available' end as status,
      count(c)
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    group by
      status;
  EOQ
}

# Analysis Queries

query "kubernetes_container_by_namespace" {
  sql = <<-EOQ
    select
      namespace,
      count(c) as "containers"
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    group by
      namespace
    order by
      namespace;
  EOQ
}

query "kubernetes_container_by_context_name" {
  sql = <<-EOQ
    select
      context_name,
      count(c) as "containers"
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    group by
      context_name
    order by
      context_name;
  EOQ
}

