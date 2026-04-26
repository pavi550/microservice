locals {
  cluster_name     = "my-eks-cluster-v2"
  namespace        = "monitoring"
  chart_name       = "kube-prometheus-stack"
  chart_repository = "https://prometheus-community.github.io/helm-charts"
  chart_version    = "57.1.1"
  name             = "monitoring"
}

resource "helm_release" "monitoring" {
  name       = local.name
  repository = local.chart_repository
  chart      = local.chart_name
  version    = local.chart_version
  namespace  = local.namespace
  create_namespace = true
  timeout    = 900
  atomic     = true
  cleanup_on_fail = true

  set {
    name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  # Avoid pre-install hook job timeouts from admission webhook cert patch jobs.
  set {
    name  = "prometheusOperator.admissionWebhooks.enabled"
    value = "false"
  }

  set {
    name  = "prometheusOperator.admissionWebhooks.patch.enabled"
    value = "false"
  }

  # Disable optional components to reduce pod count and baseline resource usage.
  set {
    name  = "alertmanager.enabled"
    value = "false"
  }

  set {
    name  = "kubeStateMetrics.enabled"
    value = "false"
  }

  set {
    name  = "prometheus-node-exporter.enabled"
    value = "false"
  }

  set {
    name  = "defaultRules.create"
    value = "false"
  }

  # Ultra-lean profile: disable control-plane/service monitors that are non-essential
  # for app-level observability on a small EKS cluster.
  set {
    name  = "kubeApiServer.enabled"
    value = "false"
  }

  set {
    name  = "kubeControllerManager.enabled"
    value = "false"
  }

  set {
    name  = "kubeScheduler.enabled"
    value = "false"
  }

  set {
    name  = "kubeEtcd.enabled"
    value = "false"
  }

  set {
    name  = "kubeProxy.enabled"
    value = "false"
  }

  set {
    name  = "coreDns.enabled"
    value = "false"
  }

  set {
    name  = "prometheusOperator.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "prometheusOperator.resources.requests.memory"
    value = "128Mi"
  }

  # Reduce default requests so the chart schedules on smaller EKS node groups.
  set {
    name  = "grafana.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "grafana.resources.requests.memory"
    value = "128Mi"
  }

  set {
    name  = "grafana.sidecar.dashboards.enabled"
    value = "false"
  }

  set {
    name  = "grafana.sidecar.datasources.enabled"
    value = "false"
  }

  set {
    name  = "prometheus.prometheusSpec.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "prometheus.prometheusSpec.resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "6h"
  }

  set {
    name  = "prometheus.prometheusSpec.scrapeInterval"
    value = "60s"
  }

  set {
    name  = "prometheus.prometheusSpec.evaluationInterval"
    value = "60s"
  }

}

