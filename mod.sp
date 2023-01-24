mod "kubernetes_insights" {
  # hub metadata
  title         = "Kubernetes Insights"
  description   = "Create dashboards and reports for your Kubernetes resources using Steampipe."
  color         = "#0089D6"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/kubernetes-insights.svg"
  categories    = ["kubernetes", "dashboard", "public cloud"]

  opengraph {
    title       = "Steampipe Mod for Kubernetes Insights"
    description = "Create dashboards and reports for your Kubernetes resources using Steampipe."
    image       = "/images/mods/turbot/kubernetes-insights-social-graphic.png"
  }

  require {
    steampipe = "0.18.0"
    plugin "kubernetes" {
      version = "0.15.0"
    }
  }
}
