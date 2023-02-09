dashboard "job_detail" {

  title         = "Kubernetes Job Detail"
  documentation = file("./dashboards/job/docs/job_detail.md")

  tags = merge(local.job_common_tags, {
    type = "Detail"
  })

  input "job_uid" {
    title = "Select a Job:"
    query = query.job_input
    width = 4
  }

  container {

    card {
      width = 3
      query = query.job_default_namespace
      args = {
        uid = self.input.job_uid.value
      }
      href = "/kubernetes_insights.dashboard.namespace_detail?input.namespace_uid={{.'UID' | @uri}}"
    }

    card {
      width = 3
      query = query.job_container_host_network
      args = {
        uid = self.input.job_uid.value
      }
    }

    card {
      width = 3
      query = query.job_container_host_pid
      args = {
        uid = self.input.job_uid.value
      }
    }

    card {
      width = 3
      query = query.job_container_host_ipc
      args = {
        uid = self.input.job_uid.value
      }
    }

  }

  with "cronjobs_for_job" {
    query = query.cronjobs_for_job
    args  = [self.input.job_uid.value]
  }

  with "pods_for_job" {
    query = query.pods_for_job
    args  = [self.input.job_uid.value]
  }

  with "nodes_for_job" {
    query = query.nodes_for_job
    args  = [self.input.job_uid.value]
  }

  with "containers_for_job" {
    query = query.containers_for_job
    args  = [self.input.job_uid.value]
  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.cronjob
        args = {
          cronjob_uids = with.cronjobs_for_job.rows[*].uid
        }
      }

      node {
        base = node.job
        args = {
          job_uids = [self.input.job_uid.value]
        }
      }

      node {
        base = node.pod
        args = {
          pod_uids = with.pods_for_job.rows[*].uid
        }
      }

      node {
        base = node.node
        args = {
          node_uids = with.nodes_for_job.rows[*].uid
        }
      }

      node {
        base = node.container
        args = {
          container_names = with.containers_for_job.rows[*].name
        }
      }

      edge {
        base = edge.cronjob_to_job
        args = {
          cronjob_uids = with.cronjobs_for_job.rows[*].uid
        }
      }

      edge {
        base = edge.container_to_node
        args = {
          container_names = with.containers_for_job.rows[*].name
        }
      }

      edge {
        base = edge.job_to_pod
        args = {
          job_uids = [self.input.job_uid.value]
        }
      }

      edge {
        base = edge.pod_to_container
        args = {
          pod_uids = with.pods_for_job.rows[*].uid
        }
      }
    }
  }

  container {

    table {
      title = "Overview"
      type  = "line"
      width = 3
      query = query.job_overview
      args = {
        uid = self.input.job_uid.value
      }

      column "Namespace" {
        href = "/kubernetes_insights.dashboard.namespace_detail?input.namespace_uid={{.'Namespace UID' | @uri}}"
      }

      column "Namespace UID" {
        display = "none"
      }
    }

    table {
      title = "Labels"
      width = 3
      query = query.job_labels
      args = {
        uid = self.input.job_uid.value
      }
    }

    table {
      title = "Annotations"
      width = 6
      query = query.job_annotations
      args = {
        uid = self.input.job_uid.value
      }
    }

  }

  container {

    chart {
      title = "Job Status"
      width = 4
      query = query.job_status_detail
      type  = "donut"
      args = {
        uid = self.input.job_uid.value
      }

      series "value" {
        point "failed" {
          color = "alert"
        }
        point "succeeded" {
          color = "ok"
        }
      }
    }

    flow {
      title = "Job Hierarchy"
      width = 8
      query = query.job_tree
      args = {
        uid = self.input.job_uid.value
      }
    }
  }

  container {

    table {
      title = "Pods"
      width = 6
      query = query.job_pods_detail
      args = {
        uid = self.input.job_uid.value
      }
      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.pod_detail.url_path}?input.pod_uid={{.UID | @uri}}"
      }

    }

    table {
      title = "Conditions"
      width = 6
      query = query.job_conditions
      args = {
        uid = self.input.job_uid.value
      }

    }

  }

}

# Input queries

query "job_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'namespace', namespace,
        'context_name', context_name
      ) as tags
    from
      kubernetes_job
    order by
      title;
  EOQ
}

# Card queries

query "job_default_namespace" {
  sql = <<-EOQ
    select
      'Namespace' as label,
      initcap(namespace) as value,
      case when namespace = 'default' then 'alert' else 'ok' end as type,
      n.uid as "UID"
    from
      kubernetes_job as j,
      kubernetes_namespace as n
    where
      n.name = j.namespace
      and n.context_name = j.context_name
      and j.uid = $1;
  EOQ

  param "uid" {}
}

query "job_container_host_network" {
  sql = <<-EOQ
    select
      'Host Network Access' as label,
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostNetwork' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_job
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "job_container_host_pid" {
  sql = <<-EOQ
    select
      'Host PID Sharing' as label,
      case when template -> 'spec' ->> 'hostPID' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostPID' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_job
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "job_container_host_ipc" {
  sql = <<-EOQ
    select
      'Host IPC Sharing' as label,
      case when template -> 'spec' ->> 'hostIPC' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when template -> 'spec' ->> 'hostIPC' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_job
    where
      uid = $1;
  EOQ

  param "uid" {}
}

# With queries

query "cronjobs_for_job" {
  sql = <<-EOQ
    select
      owner ->> 'uid' as uid
    from
      kubernetes_job as j,
      jsonb_array_elements(j.owner_references) as owner
    where
      uid = $1;
  EOQ
}

query "pods_for_job" {
  sql = <<-EOQ
    select
      pod.uid as uid
    from
      kubernetes_job as j,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      j.uid = $1
      and j.context_name = pod.context_name
      and pod_owner ->> 'uid' = j.uid;
  EOQ
}

query "nodes_for_job" {
  sql = <<-EOQ
    select
      n.uid as uid
    from
      kubernetes_job as j,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      kubernetes_node as n
    where
      n.name = pod.node_name
      and j.context_name = n.context_name
      and pod_owner ->> 'uid' = j.uid
      and j.uid = $1;
  EOQ
}

query "containers_for_job" {
  sql = <<-EOQ
    select
      container ->> 'name' || pod.name as name
    from
      kubernetes_job as j,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      jsonb_array_elements(pod.containers) as container
    where
      j.uid = $1
      and j.context_name = pod.context_name
      and pod_owner ->> 'uid' = j.uid;
  EOQ
}

# Other queries

query "job_overview" {
  sql = <<-EOQ
    select
      j.name as "Name",
      j.uid as "UID",
      j.creation_timestamp as "Create Time",
      n.uid as "Namespace UID",
      n.name as "Namespace",
      j.context_name as "Context Name"
    from
      kubernetes_job as j,
      kubernetes_namespace as n
    where
      n.name = j.namespace
      and n.context_name = j.context_name
      and j.uid = $1;
  EOQ

  param "uid" {}
}

query "job_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_job
   where
     uid = $1
   )
   select
     key as "Key",
     value as "Value"
   from
     jsondata,
     json_each_text(label)
   order by
     key;
  EOQ

  param "uid" {}
}

query "job_annotations" {
  sql = <<-EOQ
    with jsondata as (
   select
     annotations::json as annotation
   from
     kubernetes_job
   where
     uid = $1
   )
   select
     key as "Key",
     value as "Value"
   from
     jsondata,
     json_each_text(annotation)
   order by
     key;
  EOQ

  param "uid" {}
}

query "job_conditions" {
  sql = <<-EOQ
    select
      c ->> 'lastTransitionTime' as "Last Transition Time",
      c ->> 'lastUpdateTime' as "Last Update Time",
      c ->> 'message' as "Message",
      c ->> 'reason' as "Reason",
      c ->> 'status' as "Status",
      c ->> 'type' as "Type"
    from
      kubernetes_job,
      jsonb_array_elements(conditions) as c
    where
      uid = $1
    order by
      c ->> 'lastTransitionTime' desc;
  EOQ

  param "uid" {}
}

query "job_status_detail" {
  sql = <<-EOQ
    select
      case when succeeded <> 0 then 'succeeded' end as label,
      case when succeeded <> 0 then succeeded end as value
    from
      kubernetes_job
    where
      uid = $1
    union all
    select
      case when failed <> 0 then 'failed' end as label,
      case when failed <> 0 then failed end as value
    from
      kubernetes_job
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "job_pods_detail" {
  sql = <<-EOQ
    select
      pod.name as "Name",
      pod.uid as "UID",
      pod.restart_policy as "Restart Policy",
      pod.node_name as "Node Name"
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = $1
    order by
      pod.name;
  EOQ

  param "uid" {}
}

query "job_tree" {
  sql = <<-EOQ

    -- This job
    select
      null as from_id,
      uid as id,
      name as title,
      0 as depth,
      'job' as category
    from
      kubernetes_job
    where
      uid = $1

    -- Pods owned by the jobs
    union all
    select
      pod_owner ->> 'uid'  as from_id,
      pod.uid as id,
      pod.name as title,
      1 as depth,
      'pod' as category
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = $1


    -- containers in Pods owned by the jobs
    union all
    select
      pod.uid  as from_id,
      concat(pod.uid, '_', container ->> 'name') as id,
      container ->> 'name' as title,
      2 as depth,
      'container' as category
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      jsonb_array_elements(pod.containers) as container
    where
      pod_owner ->> 'uid' = $1
  EOQ


  param "uid" {}

}
