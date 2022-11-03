locals {
  kubernetes_deployment_icon  = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/deployment.svg"))
  kubernetes_pod_icon         = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/pod.svg"))
  kubernetes_replicaset_icon  = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/replicaset.svg"))
  kubernetes_namespace_icon   = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/namespace.svg"))
  kubernetes_service_icon     = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/service.svg"))
  kubernetes_node_icon        = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/node.svg"))
  kubernetes_daemonset_icon   = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/daemonset.svg"))
  kubernetes_statefulset_icon = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/statefulset.svg"))
  kubernetes_job_icon         = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/job.svg"))
  kubernetes_cronjob_icon     = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/cronjob.svg"))

}
