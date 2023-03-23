dashboard "rbac_nodes_proxy_escalate_report" {

  title         = "Kubernetes RBAC - Who can escalate privileges via node/proxy?"
  documentation = file("./dashboards/rbac/docs/rbac_nodes_proxy_escalate_report.md")

  tags = merge(local.rbac_common_tags, {
    type     = "Report"
    category = "Nodes/proxy Escalate"
  })

  input "cluster_context" {
    title = "Select a cluster:"
    query = query.cluster_input
    width = 4
  }

  with "service_accounts_for_rbac_nodes_proxy" {
    query = query.service_accounts_for_rbac
    args = {
      verb            = "create,*"
      resource        = "nodes/proxy"
      cluster_context = self.input.cluster_context.value
    }
  }

  with "role_bindings_for_rbac_nodes_proxy" {
    query = query.role_bindings_for_rbac
    args = {
      verb            = "create,*"
      resource        = "nodes/proxy"
      cluster_context = self.input.cluster_context.value
    }
  }

  with "roles_for_rbac_nodes_proxy" {
    query = query.roles_for_rbac
    args = {
      verb            = "create,*"
      resource        = "nodes/proxy"
      cluster_context = self.input.cluster_context.value
    }
  }

  container {
    graph {
      title     = "Who can escalate privileges via node/proxy?"
      type      = "graph"
      direction = "TD"
      base      = graph.rbac_resource_structure
      args = {
        rbac_role_uids            = with.roles_for_rbac_nodes_proxy.rows[*].uid
        cluster_role_uids         = with.roles_for_rbac_nodes_proxy.rows[*].uid
        role_uids                 = with.roles_for_rbac_nodes_proxy.rows[*].uid
        service_account_uids      = with.service_accounts_for_rbac_nodes_proxy.rows[*].uid
        role_binding_uids         = with.role_bindings_for_rbac_nodes_proxy.rows[*].uid
        cluster_role_binding_uids = with.role_bindings_for_rbac_nodes_proxy.rows[*].uid
        rbac_verbs                = "create,*"
        rbac_resources            = "nodes/proxy"
      }
    }
  }

  container {

    table {
      title = "Nodes/proxy RBAC Analysis"
      query = query.rbac_rule_analysis
      args = {
        verb            = "create,*"
        resource        = "nodes/proxy"
        cluster_context = self.input.cluster_context.value
      }

    }

  }

}
