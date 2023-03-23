## v0.4 [2023-03-23]

_What's new?_

- New dashboards added:
  - [Kubernetes RBAC - Who can delete events?](https://hub.steampipe.io/mods/turbot/kubernetes_insights/dashboards/dashboard.rbac_event_delete_report)
  - [Kubernetes RBAC - Who can delete pods?](https://hub.steampipe.io/mods/turbot/kubernetes_insights/dashboards/dashboard.rbac_pod_delete_report)
  - [Kubernetes RBAC - Who can escalate privileges via node/proxy?](https://hub.steampipe.io/mods/turbot/kubernetes_insights/dashboards/dashboard.rbac_nodes_proxy_escalate_report)
  - [Kubernetes RBAC - Who can exec into pods?](https://hub.steampipe.io/mods/turbot/kubernetes_insights/dashboards/dashboard.rbac_pod_exec_report)
  - [Kubernetes RBAC - Who can read secrets?](https://hub.steampipe.io/mods/turbot/kubernetes_insights/dashboards/dashboard.rbac_secret_read_report)
  - [Kubernetes RBAC Explorer](https://hub.steampipe.io/mods/turbot/kubernetes_insights/dashboards/dashboard.rbac_explorer)

## v0.3 [2023-02-17]

_Enhancements_

- Updated the `Analysis` chart width in `Kubernetes Cluster Dashboard` dashboard to enhance readability. ([#42](https://github.com/turbot/steampipe-mod-kubernetes-insights/pull/42))

_Bug fixes_

- Fixed the sankey diagram in `Kubernetes Service Detail` dashboard to correctly display the service port analysis. ([#42](https://github.com/turbot/steampipe-mod-kubernetes-insights/pull/42))
- Fixed the resource relationship graphs and other dashboard queries to make sure that resources sharing the same name across different clusters do not relay incorrect relationship information. ([#42](https://github.com/turbot/steampipe-mod-kubernetes-insights/pull/42))

## v0.2 [2023-01-24]

_Dependencies_

- Steampipe `v0.18.0` or higher is now required. ([#39](https://github.com/turbot/steampipe-mod-kubernetes-insights/pull/39))
- Kubernetes plugin `v0.15.0` or higher is now required. ([#36](https://github.com/turbot/steampipe-mod-kubernetes-insights/pull/36))

_What's new?_

- Added resource relationship graphs across all the detail dashboards to highlight the relationship the resource shares with other resources. ([#36](https://github.com/turbot/steampipe-mod-kubernetes-insights/pull/36))
- New dashboards added: ([#36](https://github.com/turbot/steampipe-mod-kubernetes-insights/pull/36))
  - [Kubernetes Cluster Role Detail](https://hub.steampipe.io/mods/turbot/kubernetes_insights/dashboards/dashboard.cluster_role_detail) 
  - [Kubernetes Role Detail](https://hub.steampipe.io/mods/turbot/kubernetes_insights/dashboards/dashboard.role_detail) 
  - [Kubernetes StatefulSet Detail](https://hub.steampipe.io/mods/turbot/kubernetes_insights/dashboards/dashboard.statefulset_detail)

## v0.1 [2022-05-16]

_What's new?_

New dashboards, reports, and details for the following services:
- Cluster
- Container
- CronJob
- DaemonSet
- Deployment
- Job
- Namespace
- Node
- Pod
- ReplicaSet
- Service
- StatefulSet
