---
repository: "https://github.com/turbot/steampipe-mod-kubernetes-insights"
---

# Kubernetes Insights Mod

Create dashboards and reports for your Kubernetes resources using Steampipe.

<!-- TO DO -->

## Overview

Dashboards can help answer questions like:

- How many resources do I have?
- How old are my resources?
- What are the various configurations of my resources?

Dashboards are available for 10+ resources, including Deployment, DaemonSet, Job, Pod, Service, Node, and more!

<!-- TO DO -->

## References

[Kubernetes](https://kubernetes.io/) also known as K8s, is an open-source system for automating deployment, scaling, and management of containerized applications.

[Steampipe](https://steampipe.io) is an open source CLI to instantly query cloud APIs using SQL.

[Steampipe Mods](https://steampipe.io/docs/reference/mod-resources#mod) are collections of `named queries`, codified `controls` that can be used to test the current configuration of your cloud resources against the desired configuration, and `dashboards` that organize and display key pieces of information.

## Documentation

- **[Dashboards →](https://hub.steampipe.io/mods/turbot/kubernetes_insights/dashboards)**

## Getting started

### Installation

Download and install Steampipe (https://steampipe.io/downloads). Or use Brew:

```sh
brew tap turbot/tap
brew install steampipe
```

Install the Kubernetes plugin with [Steampipe](https://steampipe.io):

```shell
steampipe plugin install kubernetes
```

2. Clone this repo:

```sh
git clone https://github.com/turbot/steampipe-mod-kubernetes-insights.git
cd steampipe-mod-kubernetes-insights
```

### Usage

Start your dashboard server to get started:

```shell
steampipe dashboard
```

By default, the dashboard interface will then be launched in a new browser window at https://localhost:9194.

From here, you can run dashboards by selecting one or searching for a specific one.

### Credentials

This mod uses the credentials configured in the [Steampipe Kubernetes plugin](https://hub.steampipe.io/plugins/turbot/kubernetes).

## Contributing

If you have an idea for additional dashboards or reports, or just want to help maintain and extend this mod ([or others](https://github.com/topics/steampipe-mod)) we would love you to join the community and start contributing.

- **[Join our Slack community →](https://steampipe.io/community/join)** and hang out with other Mod developers.

Please see the [contribution guidelines](https://github.com/turbot/steampipe/blob/main/CONTRIBUTING.md) and our [code of conduct](https://github.com/turbot/steampipe/blob/main/CODE_OF_CONDUCT.md). All contributions are subject to the [Apache 2.0 open source license](https://github.com/turbot/steampipe-mod-kubernetes-insights/blob/main/LICENSE).

Want to help but not sure where to start? Pick up one of the `help wanted` issues:

- [Steampipe](https://github.com/turbot/steampipe/labels/help%20wanted)
- [Kubernetes Insights Mod](https://github.com/turbot/steampipe-mod-kubernetes-insights/labels/help%20wanted)
