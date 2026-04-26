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
    name  = "prometheus.prometheusSpec.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "prometheus.prometheusSpec.resources.requests.memory"
    value = "512Mi"
  }

  set {
    name  = "alertmanager.alertmanagerSpec.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "alertmanager.alertmanagerSpec.resources.requests.memory"
    value = "128Mi"
  }
}

