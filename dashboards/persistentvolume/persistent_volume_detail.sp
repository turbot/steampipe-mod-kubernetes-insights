dashboard "persistent_volume_detail" {

  title         = "Kubernetes Persistent Volume Detail"
  documentation = file("./dashboards/persistentvolume/docs/persistent_volume_detail.md")

  tags = merge(local.persistent_volume_common_tags, {
    type = "Detail"
  })

  input "persistent_volume_uid" {
    title = "Select a Persistent Volume:"
    query = query.persistent_volume_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.persistent_volume_phase
      args = {
        uid = self.input.persistent_volume_uid.value
      }
    }

    card {
      width = 2
      query = query.persistent_volume_storage_class
      args = {
        uid = self.input.persistent_volume_uid.value
      }
    }

    card {
      width = 2
      query = query.persistent_volume_mode
      args = {
        uid = self.input.persistent_volume_uid.value
      }
    }

    card {
      width = 2
      query = query.persistent_volume_storage
      args = {
        uid = self.input.persistent_volume_uid.value
      }
    }

  }

  with "pods" {
    query = query.persistent_volume_pods
    args  = [self.input.persistent_volume_uid.value]
  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.persistent_volume
        args = {
          persistent_volume_uids = [self.input.persistent_volume_uid.value]
        }
      }

      node {
        base = node.pod
        args = {
          pod_uids = with.pods.rows[*].uid
        }
      }

      edge {
        base = edge.pod_to_persistent_volume_claim
        args = {
          pod_uids = with.pods.rows[*].uid
        }
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
        query = query.persistent_volume_overview
        args = {
          uid = self.input.persistent_volume_uid.value
        }
      }

      table {
        title = "Labels"
        width = 6
        query = query.persistent_volume_labels
        args = {
          uid = self.input.persistent_volume_uid.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Annotations"
        query = query.persistent_volume_annotations
        args = {
          uid = self.input.persistent_volume_uid.value
        }
      }

      table {
        title = "Claim Reference"
        query = query.persistent_volume_claim_ref
        args = {
          uid = self.input.persistent_volume_uid.value
        }

      }

      table {
        title = "Pods"
        query = query.persistent_volume_pods_detail
        args = {
          uid = self.input.persistent_volume_uid.value
        }

        column "UID" {
          display = "none"
        }

        column "Name" {
          href = "/kubernetes_insights.dashboard.pod_detail?input.pod_uid={{.'UID' | @uri}}"
        }

      }

    }

  }

}

# Input queries

query "persistent_volume_input" {
  sql = <<-EOQ
    select
      title as label,
      uid as value,
      json_build_object(
        'context_name', context_name
      ) as tags
    from
      kubernetes_persistent_volume
    order by
      title;
  EOQ
}

# Card queries

query "persistent_volume_phase" {
  sql = <<-EOQ
    select
      'Phase' as label,
      initcap(phase) as value,
      case when phase = 'Failed' then 'alert' else 'ok' end as type
    from
      kubernetes_persistent_volume
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "persistent_volume_storage_class" {
  sql = <<-EOQ
    select
      'Storage Class' as label,
      initcap(storage_class) as value
    from
      kubernetes_persistent_volume
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "persistent_volume_storage" {
  sql = <<-EOQ
    select
      'Capacity Storage' as label,
      capacity ->> 'storage' as value
    from
      kubernetes_persistent_volume
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "persistent_volume_mode" {
  sql = <<-EOQ
    select
      'Volume Mode' as label,
      initcap(volume_mode) as value
    from
      kubernetes_persistent_volume
    where
      uid = $1;
  EOQ

  param "uid" {}
}

# With queries

query "persistent_volume_pods" {
  sql = <<-EOQ
    select
      p.uid as uid
    from
    kubernetes_pod as p,
    jsonb_array_elements(volumes) as v
    left join kubernetes_persistent_volume as pv
    on v -> 'persistentVolumeClaim' ->> 'claimName' = pv.claim_ref ->> 'name'
    where
    pv.uid = $1;
  EOQ
}

# Other queries

query "persistent_volume_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      creation_timestamp as "Create Time",
      persistent_volume_reclaim_policy as "Reclaim Policy",
      context_name as "Context Name"
    from
      kubernetes_persistent_volume
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "persistent_volume_labels" {
  sql = <<-EOQ
    with jsondata as (
   select
     labels::json as label
   from
     kubernetes_persistent_volume
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

query "persistent_volume_annotations" {
  sql = <<-EOQ
    with jsondata as (
   select
     annotations::json as annotation
   from
     kubernetes_persistent_volume
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

query "persistent_volume_claim_ref" {
  sql = <<-EOQ
    select
      claim_ref ->> 'kind' as "Kind",
      claim_ref ->> 'name' as "Name",
      claim_ref ->> 'namespace' as "Namespace",
      claim_ref ->> 'uid' as "UID"
    from
      kubernetes_persistent_volume
    where
      uid = $1;
  EOQ

  param "uid" {}
}

query "persistent_volume_pods_detail" {
  sql = <<-EOQ
    select
      p.name as "Name",
      p.uid as "UID",
      p.namespace as "Namespace",
      p.creation_timestamp as "Create Time"
    from
      kubernetes_pod as p,
      jsonb_array_elements(volumes) as v
      left join kubernetes_persistent_volume as pv
      on v -> 'persistentVolumeClaim' ->> 'claimName' = pv.claim_ref ->> 'name'
    where
      pv.uid = $1
    order by
      p.name;
  EOQ

  param "uid" {}
}
