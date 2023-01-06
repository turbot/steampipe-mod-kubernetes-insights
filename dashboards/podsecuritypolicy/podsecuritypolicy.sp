locals {
  psp_common_tags = {
    service = "Kubernetes/PodSecurityPolicy"
  }
}

category "pod_security_policy" {
  icon  = local.kubernetes_psp_icon
  color = local.pod_security_policy_color
  title = "Pod Security Policy"
}
