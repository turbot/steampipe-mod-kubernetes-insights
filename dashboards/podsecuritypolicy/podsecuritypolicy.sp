locals {
  psp_common_tags = {
    service = "Kubernetes/PodSecurityPolicy"
  }
}

category "pod_security_policy" {
  color = local.pod_security_policy_color
  icon  = "policy"
  title = "Pod Security Policy"
}
