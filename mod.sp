mod "kubernetes_insights" {
  # Hub metadata
  title         = "Kubernetes Insights"
  description   = "Create dashboards and reports for your Kubernetes resources using Powerpipe and Steampipe."
  color         = "#0089D6"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/kubernetes-insights.svg"
  categories    = ["kubernetes", "dashboard", "public cloud"]

  opengraph {
    title       = "Powerpipe Mod for Kubernetes Insights"
    description = "Create dashboards and reports for your Kubernetes resources using Powerpipe and Steampipe."
    image       = "/images/mods/turbot/kubernetes-insights-social-graphic.png"
  }

  require {
    plugin "kubernetes" {
      min_version = "0.15.0"
    }
  }
}
