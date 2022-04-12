dashboard "kubernetes_deployment_detail" {

  title         = "Kubernetes Deployment Detail"
  documentation = file("./dashboards/deployment/docs/deployment_detail.md")

  tags = merge(local.deployment_common_tags, {
    type = "Detail"
  })

  input "deployment_uid" {
    title = "Select a deployment:"
    query = query.kubernetes_deployment_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kubernetes_deployment_container
      args = {
        uid = self.input.deployment_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_deployment_default_namespace
      args = {
        uid = self.input.deployment_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_deployment_replica
      args = {
        uid = self.input.deployment_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_deployment_container_host_network
      args = {
        uid = self.input.deployment_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_deployment_container_host_process
      args = {
        uid = self.input.deployment_uid.value
      }
    }

  }

  container {

    container {

      width = 6

      table {
        title = "Overview"
        type  = "line"
        width = 6
        query = query.kubernetes_deployment_overview
        args = {
          uid = self.input.deployment_uid.value
        }
      }

      table {
        title = "Labels"
        width = 6
        query = query.kubernetes_deployment_labels
        args = {
          uid = self.input.deployment_uid.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Conditions"
        query = query.kubernetes_deployment_conditions
        args = {
          uid = self.input.deployment_uid.value
        }

      }

      table {
        title = "Template Spec"
        query = query.kubernetes_deployment_template_spec
        args = {
          uid = self.input.deployment_uid.value
        }

      }

      table {
        title = "Strategy"
        query = query.kubernetes_deployment_strategy
        args = {
          uid = self.input.deployment_uid.value
        }

      }
    }
  }

  container {

    table {
      title = "Replicas Details"
      width = 6
      query = query.kubernetes_deployment_replicas_detail
      args = {
        uid = self.input.deployment_uid.value
      }

    }

    table {
      title = "Containers Basic details"
      width = 6
      query = query.kubernetes_deployment_container_basic_detail
      args = {
        uid = self.input.deployment_uid.value
      }

    }

    table {
      title = "Containers Access details"
      width = 6
      query = query.kubernetes_deployment_container_access_detail
      args = {
        uid = self.input.deployment_uid.value
      }

    }

    table {
      title = "Containers CPU & Memory details"
      width = 6
      query = query.kubernetes_deployment_container_cpu_detail
      args = {
        uid = self.input.deployment_uid.value
      }

    }

  }

}

query "kubernetes_deployment_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'namespace', namespace,
        'context_name', context_name
      ) as tags
    from
      kubernetes_deployment
    order by
      title;
  EOQ
}

query "kubernetes_deployment_container" {
  sql = <<-EOQ
    select
      count(c) as value,
      'Containers' as label
    from
      kubernetes_deployment,
      jsonb_array_elements(template -> 'spec' -> 'containers') as c
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_default_namespace" {
  sql = <<-EOQ
    select
      'Namespace' as label,
      initcap(namespace) as value,
      case when namespace = 'default' then 'alert' else 'ok' end as type
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_replica" {
  sql = <<-EOQ
    select
      replicas as value,
      'Replicas' as label,
      case when replicas < 3 then 'alert' else 'ok' end as type
    from
      kubernetes_deployment
    where
     uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_container_host_network" {
  sql = <<-EOQ
    select
      'Host Network Access' as label,
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_container_host_process" {
  sql = <<-EOQ
    select
      'Host Process Sharing' as label,
      case when template -> 'spec' ->> 'hostPID' = 'true'
        or template -> 'spec' ->> 'hostIPC' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostPID' = 'true'
        or template -> 'spec' ->> 'hostIPC' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      creation_timestamp as "Create Time",
      context_name as "Context Name"
    from
      kubernetes_deployment
    where
      uid = $1
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_deployment
   where
     uid = $1
   )
   select
     key as "Key",
     value as "Value"
   from
     jsondata,
     json_each_text(label);
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_conditions" {
  sql = <<-EOQ
    select
      c ->> 'lastTransitionTime' as "Last Transition Time",
      c ->> 'lastUpdateTime' as "Last Update Time",
      c ->> 'message' as "Message",
      c ->> 'reason' as "Reason",
      c ->> 'status' as "Status",
      c ->> 'type' as "Type"
    from
      kubernetes_deployment,
      jsonb_array_elements(conditions) as c
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_template_spec" {
  sql = <<-EOQ
    select
      template -> 'spec' ->> 'dnsPolicy' as "DNS Policy",
      template -> 'spec' ->> 'restartPolicy' as "Restart Policy",
      template -> 'spec' ->> 'schedulerName' as "Scheduler Name",
      template -> 'spec' ->> 'serviceAccountName' as "Service Account Name",
      template -> 'spec' ->> 'terminationGracePeriodSeconds' as "Termination Grace Period Seconds"
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_strategy" {
  sql = <<-EOQ
    select
      strategy ->> 'type' as "Type",
      strategy -> 'rollingUpdate' ->> 'maxSurge' as "Max Surge",
      strategy -> 'rollingUpdate' ->> 'maxUnavailable' as "Max Unavailable"
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_replicas_detail" {
  sql = <<-EOQ
    select
      available_replicas as "Available Replicas",
      updated_replicas as "Updated Replicas",
      ready_replicas as "Ready Replicas",
      status_replicas as "Status Replicas",
      unavailable_replicas as "Unavailable Replicas"
    from
      kubernetes_deployment
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_container_basic_detail" {
  sql = <<-EOQ
    select
      c ->> 'name' as "Name",
      c ->> 'image' as "Image",
      c -> 'securityContext' ->> 'readOnlyRootFilesystem' as "Read Only Root File System",
      c -> 'securityContext' -> 'seccompProfile' ->> 'type' as "Seccomp Profile Type"
    from
      kubernetes_deployment,
      jsonb_array_elements(template -> 'spec' -> 'containers') as c
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_container_access_detail" {
  sql = <<-EOQ
    select
      c ->> 'name' as "Name",
      c -> 'ports' ->> 'protocol' as "Protocol",
      c -> 'ports' ->> 'containerPort' as "Container Port",
      c -> 'securityContext' ->> 'allowPrivilegeEscalation' as "Allow Privilege Escalation",
      c -> 'securityContext' ->> 'privileged' as "Privileged",
      c -> 'securityContext' ->> 'runAsNonRoot' as "Run as Non Root"
    from
      kubernetes_deployment,
      jsonb_array_elements(template -> 'spec' -> 'containers') as c
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_deployment_container_cpu_detail" {
  sql = <<-EOQ
    select
      c ->> 'name' as "Name",
      c -> 'resources' -> 'limits' ->> 'cpu' as "CPU Limit",
      c -> 'resources' -> 'requests' ->> 'cpu' as "CPU Request",
      c -> 'resources' -> 'limits' ->> 'memory' as "Memory Limit",
      c -> 'resources' -> 'requests' ->> 'memory' as "Memory Request"
    from
      kubernetes_deployment,
      jsonb_array_elements(template -> 'spec' -> 'containers') as c
    where
      uid = $1;
  EOQ

  param "uid" {}
}
