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
