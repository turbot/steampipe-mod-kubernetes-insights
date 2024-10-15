dashboard "rbac_pod_exec_report" {

  title         = "Kubernetes RBAC - Who can exec into pods?"
  documentation = file("./dashboards/rbac/docs/rbac_pod_exec_report.md")

  tags = merge(local.rbac_common_tags, {
    type     = "Report"
    category = "Pod Execute"
  })

  input "cluster_context" {
    title = "Select a cluster:"
    query = query.cluster_input
    width = 4
  }

  with "service_accounts_for_rbac_pod_exec" {
    query = query.service_accounts_for_rbac
    args = {
      verb            = "*,create"
      resource        = "pods/exec,*"
      cluster_context = self.input.cluster_context.value
    }
  }

  with "role_bindings_for_rbac_pod_exec" {
    query = query.role_bindings_for_rbac
    args = {
      verb            = "*,create"
      resource        = "pods/exec,*"
      cluster_context = self.input.cluster_context.value
    }
  }

  with "roles_for_rbac_pod_exec" {
    query = query.roles_for_rbac
    args = {
      verb            = "*,create"
      resource        = "pods/exec,*"
      cluster_context = self.input.cluster_context.value
    }
  }

  container {
    graph {
      title     = "Who can exec into pods?"
      type      = "graph"
      direction = "TD"
      base      = graph.rbac_resource_structure
      args = {
        rbac_role_uids            = with.roles_for_rbac_pod_exec.rows[*].uid
        cluster_role_uids         = with.roles_for_rbac_pod_exec.rows[*].uid
        role_uids                 = with.roles_for_rbac_pod_exec.rows[*].uid
        service_account_uids      = with.service_accounts_for_rbac_pod_exec.rows[*].uid
        role_binding_uids         = with.role_bindings_for_rbac_pod_exec.rows[*].uid
        cluster_role_binding_uids = with.role_bindings_for_rbac_pod_exec.rows[*].uid
        rbac_verbs                = "*,create"
        rbac_resources            = "pods/exec,*"
      }
    }
  }

  container {

    table {
      title = "Secrets RBAC Analysis"
      query = query.rbac_rule_analysis
      args = {
        verb            = "*,create"
        resource        = "pods/exec,*"
        cluster_context = self.input.cluster_context.value
      }

    }

  }

}
