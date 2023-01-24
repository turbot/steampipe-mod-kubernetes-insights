dashboard "container_dashboard" {

  title         = "Kubernetes Container Dashboard"
  documentation = file("./dashboards/container/docs/container_dashboard.md")

  tags = merge(local.container_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.container_count
      width = 2
    }

    card {
      query = query.container_privileged_count
      width = 2
    }

    card {
      query = query.container_allow_privilege_escalation_count
      width = 2
    }

    card {
      query = query.container_liveness_probe_count
      width = 2
    }

    card {
      query = query.container_readiness_probe_count
      width = 2
    }

    card {
      query = query.container_immutable_root_filesystem_count
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Privileged Status"
      query = query.container_privileged_status
      type  = "donut"
      width = 4

      series "count" {
        point "enabled" {
          color = "alert"
        }
        point "disabled" {
          color = "ok"
        }
      }
    }

    chart {
      title = "Privilege Escalation Status"
      query = query.container_allow_privilege_escalation_status
      type  = "donut"
      width = 4

      series "count" {
        point "enabled" {
          color = "alert"
        }
        point "disabled" {
          color = "ok"
        }
      }
    }

    chart {
      title = "Liveness Probe Status"
      query = query.container_liveness_probe_status
      type  = "donut"
      width = 4

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
      query = query.container_readiness_probe_status
      type  = "donut"
      width = 4

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
      title = "Immutable Root Filesystem Status"
      query = query.container_immutable_root_filesystem_status
      type  = "donut"
      width = 4

      series "count" {
        point "unused" {
          color = "alert"
        }
        point "used" {
          color = "ok"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Containers by Cluster"
      query = query.container_by_context_name
      type  = "column"
      width = 4
    }

    chart {
      title = "Containers by Namespace"
      query = query.container_by_namespace
      type  = "column"
      width = 4
    }

    chart {
      title = "Containers by Pod"
      query = query.container_by_pod
      type  = "column"
      width = 4
    }

  }

}

# Card Queries

query "container_count" {
  sql = <<-EOQ
    select
      count(c) as "Containers"
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c;
  EOQ
}

query "container_privileged_count" {
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

query "container_allow_privilege_escalation_count" {
  sql = <<-EOQ
    select
      count(c ->> 'name') as value,
      'Privilege Escalation Enabled' as label,
      case count(c ->> 'name') when 0 then 'ok' else 'alert' end as type
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      c -> 'securityContext' ->> 'allowPrivilegeEscalation' = 'true';
  EOQ
}

query "container_liveness_probe_count" {
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

query "container_readiness_probe_count" {
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

query "container_immutable_root_filesystem_count" {
  sql = <<-EOQ
    select
      count(c ->> 'name') as value,
      'Immutable Root Filesystem Unused' as label,
      case count(c ->> 'name') when 0 then 'ok' else 'alert' end as type
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    where
      c -> 'securityContext' ->> 'readOnlyRootFilesystem' = 'false' or c -> 'securityContext' ->> 'readOnlyRootFilesystem' is null;
  EOQ
}

# Assessment Queries

query "container_privileged_status" {
  sql = <<-EOQ
    select
      case when c -> 'securityContext' ->> 'privileged' = 'true' then 'enabled' else 'disabled' end as status,
      count(c)
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    group by
      status;
  EOQ
}

query "container_allow_privilege_escalation_status" {
  sql = <<-EOQ
    select
      case when c -> 'securityContext' ->> 'allowPrivilegeEscalation' = 'true' then 'enabled' else 'disabled' end as status,
      count(c)
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    group by
      status;
  EOQ
}

query "container_liveness_probe_status" {
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

query "container_readiness_probe_status" {
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

query "container_immutable_root_filesystem_status" {
  sql = <<-EOQ
    select
      case when c -> 'securityContext' ->> 'readOnlyRootFilesystem' = 'true' then 'used' else 'unused' end as status,
      count(c)
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    group by
      status;
  EOQ
}

# Analysis Queries

query "container_by_namespace" {
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

query "container_by_context_name" {
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

query "container_by_pod" {
  sql = <<-EOQ
    select
      name,
      count(c) as "containers"
    from
      kubernetes_pod,
      jsonb_array_elements(containers) as c
    group by
      name
    order by
      name;
  EOQ
}
