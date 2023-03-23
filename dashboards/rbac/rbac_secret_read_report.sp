dashboard "rbac_secret_read_report" {

  title         = "Kubernetes RBAC - Who can read secrets?"
  documentation = file("./dashboards/rbac/docs/rbac_secret_read_report.md")

  tags = merge(local.rbac_common_tags, {
    type     = "Report"
    category = "Secret Read"
  })

  input "cluster_context" {
    title = "Select a cluster:"
    query = query.cluster_input
    width = 4
  }

  with "service_accounts_for_rbac_secret" {
    query = query.service_accounts_for_rbac
    args = {
      verb            = "describe"
      resource        = "secrets"
      cluster_context = self.input.cluster_context.value
    }
  }

  with "role_bindings_for_rbac_secret" {
    query = query.role_bindings_for_rbac
    args = {
      verb            = "describe"
      resource        = "secrets"
      cluster_context = self.input.cluster_context.value
    }
  }

  with "roles_for_rbac_secret" {
    query = query.roles_for_rbac
    args = {
      verb            = "describe"
      resource        = "secrets"
      cluster_context = self.input.cluster_context.value
    }
  }

  container {
    graph {
      title     = "Who can read secrets?"
      type      = "graph"
      direction = "TD"
      base      = graph.rbac_resource_structure
      args = {
        rbac_role_uids            = with.roles_for_rbac_secret.rows[*].uid
        cluster_role_uids         = with.roles_for_rbac_secret.rows[*].uid
        role_uids                 = with.roles_for_rbac_secret.rows[*].uid
        service_account_uids      = with.service_accounts_for_rbac_secret.rows[*].uid
        role_binding_uids         = with.role_bindings_for_rbac_secret.rows[*].uid
        cluster_role_binding_uids = with.role_bindings_for_rbac_secret.rows[*].uid
        rbac_verbs                = "describe"
        rbac_resources            = "secrets"
      }
    }
  }

  container {

    table {
      title = "Secrets RBAC Analysis"
      query = query.rbac_rule_analysis
      args = {
        verb            = "describe"
        resource        = "secrets"
        cluster_context = self.input.cluster_context.value
      }

    }

  }

}
