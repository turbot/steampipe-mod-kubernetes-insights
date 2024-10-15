dashboard "rbac_pod_delete_report" {

  title         = "Kubernetes RBAC - Who can delete pods?"
  documentation = file("./dashboards/rbac/docs/rbac_pod_delete_report.md")

  tags = merge(local.rbac_common_tags, {
    type     = "Report"
    category = "Pod Delete"
  })

  input "cluster_context" {
    title = "Select a cluster:"
    query = query.cluster_input
    width = 4
  }

  with "service_accounts_for_rbac_pod" {
    query = query.service_accounts_for_rbac
    args = {
      verb            = "delete"
      resource        = "pods"
      cluster_context = self.input.cluster_context.value
    }
  }

  with "role_bindings_for_rbac_pod" {
    query = query.role_bindings_for_rbac
    args = {
      verb            = "delete"
      resource        = "pods"
      cluster_context = self.input.cluster_context.value
    }
  }

  with "roles_for_rbac_pod" {
    query = query.roles_for_rbac
    args = {
      verb            = "delete"
      resource        = "pods"
      cluster_context = self.input.cluster_context.value
    }
  }

  container {
    graph {
      title     = "Who can delete pods?"
      type      = "graph"
      direction = "TD"
      base      = graph.rbac_resource_structure
      args = {
        rbac_role_uids            = with.roles_for_rbac_pod.rows[*].uid
        cluster_role_uids         = with.roles_for_rbac_pod.rows[*].uid
        role_uids                 = with.roles_for_rbac_pod.rows[*].uid
        service_account_uids      = with.service_accounts_for_rbac_pod.rows[*].uid
        role_binding_uids         = with.role_bindings_for_rbac_pod.rows[*].uid
        cluster_role_binding_uids = with.role_bindings_for_rbac_pod.rows[*].uid
        rbac_verbs                = "delete"
        rbac_resources            = "pods"
      }
    }
  }

  container {

    table {
      title = "Pods RBAC Analysis"
      query = query.rbac_rule_analysis
      args = {
        verb            = "delete"
        resource        = "pods"
        cluster_context = self.input.cluster_context.value
      }

    }

  }

}
