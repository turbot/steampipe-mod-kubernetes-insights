locals {
  psp_common_tags = {
    service = "Kubernetes/PodSecurityPolicy"
  }
}

category "pod_security_policy" {
  //icon  = local.kubernetes_psp_icon
  icon  = "policy"
  title = "Pod Security Policy"
}
