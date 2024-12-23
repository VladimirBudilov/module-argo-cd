provider "kubernetes" {
  cluster_ca_certificate = base64decode(var.kubernetes_cluster_cert_data)
  host                   = var.kubernetes_cluster_endpoint
  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.kubernetes_cluster_name]
  }
}

provider "helm" {
  kubernetes {
    cluster_ca_certificate = base64decode(var.kubernetes_cluster_cert_data)
    host                   = var.kubernetes_cluster_endpoint
    exec {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.kubernetes_cluster_name]
    }
  }
}

resource "kubernetes_namespace" "argo_ns" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "msur"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  namespace  = kubernetes_namespace.argo_ns.metadata[0].name
  version    = "5.34.2" # Укажите нужную версию

  set {
    name  = "controller.extraArgs"
    value = "insecure"
  }

  set {
    name  = "crds.install"
    value = true
  }

  # Добавлено автоматическое управление RBAC, если нужно
  set {
    name  = "rbac.create"
    value = true
  }
}
