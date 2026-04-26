locals {
    cluster_name           = "monitoring-cluster"
    namespace                = "default"
    chart_name                = "kube-prometheus-stack"
    chart_repository            = "https://prometheus-community.github.io/helm-charts"
    chart_version             = "57.1.1"
    name                     = "monitoring"
 
}

resource "helm_release" "monitoring" {
  name       = local.name
  repository = local.chart_repository
  chart      = local.chart_name
  version    = local.chart_version
  namespace  = local.namespace

  set {
    name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = "false"
  }
}

