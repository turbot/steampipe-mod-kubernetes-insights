# Kubernetes Insights Mod for Steampipe

A Kubernetes dashboarding tool that can be used to view dashboards and reports across all of your Kubernetes clusters.

![image](https://raw.githubusercontent.com/turbot/steampipe-mod-kubernetes-insights/main/docs/images/kubernetes_container_dashboard.png)

## Overview

Dashboards can help answer questions like:

- How many resources do I have?
- How old are my resources?
- What are the various configurations of my resources?
- What are the relationships between closely connected resources like clusters, nodes, pods, deployments and jobs?
- Who can perform operations like list, get, read etc. on my resources?

Dashboards are available for 10+ resources, including Clusters, DaemonSets, Deployments, Nodes, Pods, Services, and more. Dashboards are also available for RBAC security controls, where you can check the assigned permissions to different resources.

## Getting started

### Installation

Download and install Steampipe (https://steampipe.io/downloads). Or use Brew:

```sh
brew tap turbot/tap
brew install steampipe
```

Install the Kubernetes plugin with [Steampipe](https://steampipe.io):

```sh
steampipe plugin install kubernetes
```

Clone this repo:

```sh
git clone https://github.com/turbot/steampipe-mod-kubernetes-insights.git
cd steampipe-mod-kubernetes-insights
```

### Usage

Start your dashboard server to get started:

```sh
steampipe dashboard
```

By default, the dashboard interface will then be launched in a new browser window at https://localhost:9194. From here, you can view dashboards and reports.

### Credentials

This mod uses the credentials configured in the [Steampipe Kubernetes plugin](https://hub.steampipe.io/plugins/turbot/kubernetes).

### Configuration

No extra configuration is required.

## Contributing

If you have an idea for additional dashboards or reports, or just want to help maintain and extend this mod ([or others](https://github.com/topics/steampipe-mod)) we would love you to join the community and start contributing.

- **[Join #steampipe on Slack →](https://turbot.com/community/join)** and hang out with other Mod developers.

Please see the [contribution guidelines](https://github.com/turbot/steampipe/blob/main/CONTRIBUTING.md) and our [code of conduct](https://github.com/turbot/steampipe/blob/main/CODE_OF_CONDUCT.md). All contributions are subject to the [Apache 2.0 open source license](https://github.com/turbot/steampipe-mod-kubernetes-insights/blob/main/LICENSE).

Want to help but not sure where to start? Pick up one of the `help wanted` issues:

- [Steampipe](https://github.com/turbot/steampipe/labels/help%20wanted)
- [Kubernetes Insights Mod](https://github.com/turbot/steampipe-mod-kubernetes-insights/labels/help%20wanted)
