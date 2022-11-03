dashboard "kubernetes_cronjob_detail" {

  title         = "Kubernetes CronJob Detail"
  documentation = file("./dashboards/cronjob/docs/cronjob_detail.md")

  tags = merge(local.cronjob_common_tags, {
    type = "Detail"
  })

  input "cronjob_uid" {
    title = "Select a CronJob:"
    query = query.kubernetes_cronjob_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kubernetes_cronjob_default_namespace
      args = {
        uid = self.input.cronjob_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_cronjob_container_host_network
      args = {
        uid = self.input.cronjob_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_cronjob_container_host_pid
      args = {
        uid = self.input.cronjob_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_cronjob_container_host_ipc
      args = {
        uid = self.input.cronjob_uid.value
      }
    }

  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "LR"

      nodes = [
        node.kubernetes_cronjob_node,
        node.kubernetes_cronjob_to_job_node,
        node.kubernetes_cronjob_from_namespace_node,
        node.kubernetes_cronjob_to_job_to_pod_node,
        node.kubernetes_cronjob_to_job_to_pod_to_container_node,
        node.kubernetes_cronjob_to_job_to_pod_to_node_node
      ]

      edges = [
        edge.kubernetes_cronjob_to_job_edge,
        edge.kubernetes_cronjob_from_namespace_edge,
        edge.kubernetes_cronjob_to_job_to_pod_edge,
        edge.kubernetes_cronjob_to_job_to_pod_to_container_edge,
        edge.kubernetes_cronjob_to_job_to_pod_to_node_edge
      ]

      args = {
        uid = self.input.cronjob_uid.value
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
        query = query.kubernetes_cronjob_overview
        args = {
          uid = self.input.cronjob_uid.value
        }
      }

      table {
        title = "Labels"
        width = 6
        query = query.kubernetes_cronjob_labels
        args = {
          uid = self.input.cronjob_uid.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Annotations"
        query = query.kubernetes_cronjob_annotations
        args = {
          uid = self.input.cronjob_uid.value
        }
      }

      table {
        title = "Configuration"
        query = query.kubernetes_cronjob_configuration_detail
        args = {
          uid = self.input.cronjob_uid.value
        }

      }

    }

  }

  container {

    flow {
      title = "CronJob Hierarchy"
      query = query.kubernetes_cronjob_tree
      args = {
        uid = self.input.cronjob_uid.value
      }
    }

    table {
      column "UID" {
        display = "none"
      }

      title = "Jobs"
      width = 6
      query = query.kubernetes_cronjob_jobs
      args = {
        uid = self.input.cronjob_uid.value
      }
      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.kubernetes_job_detail.url_path}?input.job_uid={{.UID | @uri}}"
      }
    }

    table {
      title = "Pods"
      width = 6
      query = query.kubernetes_cronjob_pods
      args = {
        uid = self.input.cronjob_uid.value
      }
      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.kubernetes_pod_detail.url_path}?input.pod_uid={{.UID | @uri}}"
      }

    }


  }

}

category "kubernetes_cronjob_no_link" {
  icon = local.kubernetes_cronjob_icon
}

node "kubernetes_cronjob_node" {
  category = category.kubernetes_cronjob_no_link

  sql = <<-EOQ
    select
      uid as id,
      title as title,
      jsonb_build_object(
        'UID', uid,
        'Namespace', namespace,
        'Context Name', context_name
      ) as properties
    from
      kubernetes_cronjob
    where
      uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_cronjob_from_namespace_node" {
  category = category.kubernetes_namespace

  sql = <<-EOQ
    select
      n.uid as id,
      n.title as title,
      jsonb_build_object(
        'UID', n.uid,
        'Phase', n.phase,
        'Context Name', n.context_name
      ) as properties
    from
      kubernetes_namespace as n,
      kubernetes_cronjob as c
    where
      n.name = c.namespace
      and c.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_cronjob_from_namespace_edge" {
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
      and c.uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_cronjob_to_job_node" {
  category = category.kubernetes_job

  sql = <<-EOQ
    select
      j.uid as id,
      j.title as title,
      jsonb_build_object(
        'UID', j.uid,
        'Namespace', j.namespace,
        'Context Name', j.context_name
      ) as properties
    from
      kubernetes_job as j,
      jsonb_array_elements(j.owner_references) as owner
    where
      owner ->> 'uid' = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_cronjob_to_job_edge" {
  title = "job"

  sql = <<-EOQ
     select
      owner ->> 'uid' as from_id,
      j.uid as to_id
    from
      kubernetes_job as j,
      jsonb_array_elements(j.owner_references) as owner
    where
      owner ->> 'uid' = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_cronjob_to_job_to_pod_node" {
  category = category.kubernetes_pod

  sql = <<-EOQ
    select
      pod.uid as id,
      pod.title as title,
      jsonb_build_object(
        'UID', pod.uid,
        'Namespace', pod.namespace,
        'Context Name', pod.context_name
      ) as properties
    from
      kubernetes_job as j,
      jsonb_array_elements(j.owner_references) as j_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      j_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = j.uid;
  EOQ

  param "uid" {}
}

edge "kubernetes_cronjob_to_job_to_pod_edge" {
  title = "pod"

  sql = <<-EOQ
     select
      j.uid as from_id,
      pod.uid as to_id
    from
      kubernetes_job as j,
      jsonb_array_elements(j.owner_references) as j_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      j_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = j.uid;
  EOQ

  param "uid" {}
}

node "kubernetes_cronjob_to_job_to_pod_to_container_node" {
  category = category.kubernetes_container

  sql = <<-EOQ
    select
      container ->> 'name' || pod.name as id,
      container ->> 'name' as title,
      jsonb_build_object(
        'Name', container ->> 'name',
        'Image', container ->> 'image',
        'POD Name', pod.name
      ) as properties
    from
      kubernetes_job as j,
      jsonb_array_elements(j.owner_references) as j_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      jsonb_array_elements(pod.containers) as container
    where
      j_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = j.uid;
  EOQ

  param "uid" {}
}

edge "kubernetes_cronjob_to_job_to_pod_to_container_edge" {
  title = "container"

  sql = <<-EOQ
     select
      pod.uid as from_id,
      container ->> 'name' || pod.name as to_id
    from
      kubernetes_job as j,
      jsonb_array_elements(j.owner_references) as j_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      jsonb_array_elements(pod.containers) as container
    where
      j_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = j.uid;
  EOQ

  param "uid" {}
}

node "kubernetes_cronjob_to_job_to_pod_to_node_node" {
  category = category.kubernetes_node

  sql = <<-EOQ
    select
      n.uid as id,
      n.name as title,
      jsonb_build_object(
        'UID', n.uid,
        'POD CIDR', n.pod_cidr,
        'Context Name', n.context_name
      ) as properties
    from
      kubernetes_job as j,
      jsonb_array_elements(j.owner_references) as j_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      kubernetes_node as n
    where
      n.name = pod.node_name
      and pod_owner ->> 'uid' = j.uid
      and j_owner ->> 'uid' = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_cronjob_to_job_to_pod_to_node_edge" {
  title = "node"

  sql = <<-EOQ
    select
      n.uid as to_id,
      pod.uid as from_id
    from
      kubernetes_job as j,
      jsonb_array_elements(j.owner_references) as j_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      kubernetes_node as n
    where
      n.name = pod.node_name
      and pod_owner ->> 'uid' = j.uid
      and j_owner ->> 'uid' = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_cronjob_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'namespace', namespace,
        'context_name', context_name
      ) as tags
    from
      kubernetes_cronjob
    order by
      title;
  EOQ
}

query "kubernetes_cronjob_default_namespace" {
  sql = <<-EOQ
    select
      'Namespace' as label,
      initcap(namespace) as value,
      case when namespace = 'default' then 'alert' else 'ok' end as type
    from
      kubernetes_cronjob
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_cronjob_container_host_network" {
  sql = <<-EOQ
    select
      'Host Network Access' as label,
      case when job_template -> 'spec' -> 'template' -> 'spec' ->> 'hostNetwork' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when job_template -> 'spec' -> 'template' -> 'spec' ->> 'hostNetwork' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_cronjob
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_cronjob_container_host_pid" {
  sql = <<-EOQ
    select
      'Host PID Sharing' as label,
      case when job_template -> 'spec' -> 'template' -> 'spec' ->> 'hostPID' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when job_template -> 'spec' -> 'template' -> 'spec' ->> 'hostPID' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_cronjob
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_cronjob_container_host_ipc" {
  sql = <<-EOQ
    select
      'Host IPC Sharing' as label,
      case when job_template -> 'spec' -> 'template' -> 'spec' ->> 'hostIPC' = 'true' then 'Enabled' else 'Disabled' end as value,
      case when job_template -> 'spec' -> 'template' -> 'spec' ->> 'hostIPC' = 'true' then 'alert' else 'ok' end as type
    from
      kubernetes_cronjob
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_cronjob_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      creation_timestamp as "Create Time",
      context_name as "Context Name"
    from
      kubernetes_cronjob
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_cronjob_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_cronjob
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

query "kubernetes_cronjob_annotations" {
  sql = <<-EOQ
    with jsondata as (
   select
     annotations::json as annotation
   from
     kubernetes_cronjob
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

query "kubernetes_cronjob_configuration_detail" {
  sql = <<-EOQ
    select
      schedule as "Schedule",
      active as "Active",
      suspend as "Suspend",
      concurrency_policy as "Concurrency Policy",
      last_schedule_time as "Last Schedule Time",
      last_successful_time as "Last Successful Time",
      successful_jobs_history_limit as "Successful Jobs History Limit",
      failed_jobs_history_limit as "Failed Jobs History Limit"
    from
      kubernetes_cronjob
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_cronjob_jobs" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      start_time as "Start Time",
      completion_time as "Create Time"
    from
      kubernetes_job,
      jsonb_array_elements(owner_references) as owner
    where
      owner ->> 'uid' = $1
    order by
      name;
  EOQ

  param "uid" {}
}

query "kubernetes_cronjob_pods" {
  sql = <<-EOQ
    select
      pod.name as "Name",
      pod.uid as "UID",
      pod.restart_policy as "Restart Policy",
      pod.node_name as "Node Name"
    from
      kubernetes_job as j,
      jsonb_array_elements(j.owner_references) as j_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      j_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = j.uid
    order by
      pod.name;
  EOQ

  param "uid" {}
}

query "kubernetes_cronjob_tree" {
  sql = <<-EOQ

    -- This cronjob
    select
      null as from_id,
      uid as id,
      name as title,
      0 as depth,
      'cronjob' as category
    from
      kubernetes_cronjob
    where
      uid = $1

    -- jobs owned by the cronjob
    union all
    select
      $1 as from_id,
      uid as id,
      name as title,
      1 as depth,
      'job' as category
    from
      kubernetes_job,
      jsonb_array_elements(owner_references) as owner
    where
      owner ->> 'uid' = $1

    -- Pods owned by the jobs
    union all
    select
      pod_owner ->> 'uid'  as from_id,
      pod.uid as id,
      pod.name as title,
      2 as depth,
      'pod' as category
    from
      kubernetes_job as j,
      jsonb_array_elements(j.owner_references) as j_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      j_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = j.uid


    -- containers in Pods owned by the jobs
    union all
    select
      pod.uid  as from_id,
      concat(pod.uid, '_', container ->> 'name') as id,
      container ->> 'name' as title,
      3 as depth,
      'container' as category
    from
      kubernetes_job as j,
      jsonb_array_elements(j.owner_references) as j_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      jsonb_array_elements(pod.containers) as container
    where
      j_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = j.uid
  EOQ

  param "uid" {}
}
