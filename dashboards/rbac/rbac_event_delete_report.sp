dashboard "rbac_event_delete_report" {

  title         = "Kubernetes RBAC - Who can delete events?"
  documentation = file("./dashboards/rbac/docs/rbac_event_delete_report.md")

  tags = merge(local.rbac_common_tags, {
    type     = "Report"
    category = "Event Delete"
  })

  input "cluster_context" {
    title = "Select a cluster:"
    query = query.cluster_input
    width = 4
  }

  with "service_accounts_for_rbac_event" {
    query = query.service_accounts_for_rbac
    args = {
      verb            = "delete"
      resource        = "events"
      cluster_context = self.input.cluster_context.value
    }
  }

  with "role_bindings_for_rbac_event" {
    query = query.role_bindings_for_rbac
    args = {
      verb            = "delete"
      resource        = "events"
      cluster_context = self.input.cluster_context.value
    }
  }

  with "roles_for_rbac_event" {
    query = query.roles_for_rbac
    args = {
      verb            = "delete"
      resource        = "events"
      cluster_context = self.input.cluster_context.value
    }
  }

  container {
    graph {
      title     = "Who can delete events?"
      type      = "graph"
      direction = "TD"
      base      = graph.rbac_resource_structure
      args = {
        rbac_role_uids            = with.roles_for_rbac_event.rows[*].uid
        cluster_role_uids         = with.roles_for_rbac_event.rows[*].uid
        role_uids                 = with.roles_for_rbac_event.rows[*].uid
        service_account_uids      = with.service_accounts_for_rbac_event.rows[*].uid
        role_binding_uids         = with.role_bindings_for_rbac_event.rows[*].uid
        cluster_role_binding_uids = with.role_bindings_for_rbac_event.rows[*].uid
        rbac_verbs                = "delete"
        rbac_resources            = "events"
      }
    }
  }

  container {

    table {
      title = "Events RBAC Analysis"
      query = query.rbac_rule_analysis
      args = {
        verb            = "delete"
        resource        = "events"
        cluster_context = self.input.cluster_context.value
      }

    }

  }
}
