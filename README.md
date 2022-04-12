# Kubernetes Insights

A kubernetes dashboarding tool that can be used to view dashboards and reports across all of your Kubernetes clusters.

<!-- TO DO-->

## Overview

Dashboards can help answer questions like:

- How many resources do I have?
- How old are my resources?
- Are there any publicly accessible resources?
<!-- - Is encryption enabled and what keys are used for encryption? -->
<!-- - Is versioning enabled? -->

<!-- TO DO -->

## Getting started

### Installation

1) Download and install Steampipe (https://steampipe.io/downloads). Or use Brew:

```shell
brew tap turbot/tap
brew install steampipe

steampipe -v
steampipe version 0.13.0
```

2) Install the Kubernetes plugin:

```shell
steampipe plugin install kubernetes
```

3) Clone this repo:

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

From here, you can view all of your dashboards and reports.

## Contributing

If you have an idea for additional dashboards or reports, or just want to help maintain and extend this mod ([or others](https://github.com/topics/steampipe-mod)) we would love you to join the community and start contributing.

- **[Join our Slack community →](https://steampipe.io/community/join)** and hang out with other Mod developers.

Please see the [contribution guidelines](https://github.com/turbot/steampipe/blob/main/CONTRIBUTING.md) and our [code of conduct](https://github.com/turbot/steampipe/blob/main/CODE_OF_CONDUCT.md). All contributions are subject to the [Apache 2.0 open source license](https://github.com/turbot/steampipe-mod-kubernetes-insights/blob/main/LICENSE).

Want to help but not sure where to start? Pick up one of the `help wanted` issues:

- [Steampipe](https://github.com/turbot/steampipe/labels/help%20wanted)
- [Kubernetes Insights Mod](https://github.com/turbot/steampipe-mod-kubernetes-insights/labels/help%20wanted)
