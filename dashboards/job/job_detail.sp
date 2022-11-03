dashboard "kubernetes_job_detail" {

  title         = "Kubernetes Job Detail"
  documentation = file("./dashboards/job/docs/job_detail.md")

  tags = merge(local.job_common_tags, {
    type = "Detail"
  })

  input "job_uid" {
    title = "Select a Job:"
    query = query.kubernetes_job_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kubernetes_job_default_namespace
      args = {
        uid = self.input.job_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_job_container_host_network
      args = {
        uid = self.input.job_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_job_container_host_pid
      args = {
        uid = self.input.job_uid.value
      }
    }

    card {
      width = 2
      query = query.kubernetes_job_container_host_ipc
      args = {
        uid = self.input.job_uid.value
      }
    }

  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "LR"

      nodes = [
        node.kubernetes_job_node,
        node.kubernetes_job_from_namespace_node,
        node.kubernetes_job_to_pod_node,
        node.kubernetes_job_to_pod_to_container_node,
        node.kubernetes_job_to_pod_to_node_node,
        node.kubernetes_job_from_cronjob_node
      ]

      edges = [
        edge.kubernetes_job_to_pod_edge,
        edge.kubernetes_job_from_namespace_edge,
        edge.kubernetes_job_to_pod_to_container_edge,
        edge.kubernetes_job_to_pod_to_node_edge,
        edge.kubernetes_job_from_cronjob_edge
      ]

      args = {
        uid = self.input.job_uid.value
      }
    }
  }

  container {

    table {
      title = "Overview"
      type  = "line"
      width = 3
      query = query.kubernetes_job_overview
      args = {
        uid = self.input.job_uid.value
      }
    }

    table {
      title = "Labels"
      width = 3
      query = query.kubernetes_job_labels
      args = {
        uid = self.input.job_uid.value
      }
    }

    table {
      title = "Annotations"
      width = 6
      query = query.kubernetes_job_annotations
      args = {
        uid = self.input.job_uid.value
      }
    }

  }

  container {

    chart {
      title = "Job Status"
      width = 4
      query = query.kubernetes_job_pods_detail
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
      query = query.kubernetes_job_tree
      args = {
        uid = self.input.job_uid.value
      }
    }
  }

  container {

    table {
      title = "Pods"
      width = 6
      query = query.kubernetes_job_pods
      args = {
        uid = self.input.job_uid.value
      }
      column "UID" {
        display = "none"
      }

      column "Name" {
        href = "${dashboard.kubernetes_pod_detail.url_path}?input.pod_uid={{.UID | @uri}}"
      }

    }

    table {
      title = "Conditions"
      width = 6
      query = query.kubernetes_job_conditions
      args = {
        uid = self.input.job_uid.value
      }

    }

  }

}

category "kubernetes_job_no_link" {
  icon = local.kubernetes_job_icon
}

node "kubernetes_job_node" {
  category = category.kubernetes_job_no_link

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
      kubernetes_job
    where
      uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_job_from_namespace_node" {
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
      kubernetes_job as d
    where
      n.name = d.namespace
      and d.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_job_from_namespace_edge" {
  title = "job"

  sql = <<-EOQ
     select
      n.uid as from_id,
      d.uid as to_id
    from
      kubernetes_namespace as n,
      kubernetes_job as d
    where
      n.name = d.namespace
      and d.uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_job_from_cronjob_node" {
  category = category.kubernetes_cronjob

  sql = <<-EOQ
    select
      c.uid as id,
      c.title as title,
      jsonb_build_object(
        'UID', c.uid,
        'Schedule', c.schedule,
        'Context Name', c.context_name
      ) as properties
    from
      kubernetes_cronjob as c,
      kubernetes_job as j,
      jsonb_array_elements(j.owner_references) as owner
    where
      owner ->> 'uid' = c.uid
      and j.uid = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_job_from_cronjob_edge" {
  title = "cronjob"

  sql = <<-EOQ
     select
      c.uid as from_id,
      j.uid as to_id
    from
      kubernetes_cronjob as c,
      kubernetes_job as j,
      jsonb_array_elements(j.owner_references) as owner
    where
      owner ->> 'uid' = c.uid
      and j.uid = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_job_to_pod_node" {
  category = category.kubernetes_pod

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
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_job_to_pod_edge" {
  title = "pod"

  sql = <<-EOQ
     select
      pod_owner ->> 'uid' as from_id,
      uid as to_id
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      pod_owner ->> 'uid' = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_job_to_pod_to_container_node" {
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
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      jsonb_array_elements(pod.containers) as container
    where
      pod_owner ->> 'uid' = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_job_to_pod_to_container_edge" {
  title = "container"

  sql = <<-EOQ
     select
      pod.uid as from_id,
      container ->> 'name' || pod.name as to_id
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      jsonb_array_elements(pod.containers) as container
    where
      pod_owner ->> 'uid' = $1;
  EOQ

  param "uid" {}
}

node "kubernetes_job_to_pod_to_node_node" {
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
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      kubernetes_node as n
    where
      n.name = pod.node_name
      and pod_owner ->> 'uid' = $1;
  EOQ

  param "uid" {}
}

edge "kubernetes_job_to_pod_to_node_edge" {
  title = "node"

  sql = <<-EOQ
    select
      n.uid as to_id,
      pod.uid as from_id
    from
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      kubernetes_node as n
    where
      n.name = pod.node_name
      and pod_owner ->> 'uid' = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_job_input" {
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

query "kubernetes_job_default_namespace" {
  sql = <<-EOQ
    select
      'Namespace' as label,
      initcap(namespace) as value,
      case when namespace = 'default' then 'alert' else 'ok' end as type
    from
      kubernetes_job
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_job_container_host_network" {
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

query "kubernetes_job_container_host_pid" {
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

query "kubernetes_job_container_host_ipc" {
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

query "kubernetes_job_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      creation_timestamp as "Create Time",
      context_name as "Context Name"
    from
      kubernetes_job
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "kubernetes_job_labels" {
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

query "kubernetes_job_annotations" {
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

query "kubernetes_job_conditions" {
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

query "kubernetes_job_pods_detail" {
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

query "kubernetes_job_pods" {
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

query "kubernetes_job_tree" {
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
