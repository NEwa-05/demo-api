resource "scaleway_k8s_cluster" "kube-par" {
  name    = "kube-par"
  region = "fr-par"
  version = "1.22.1"
  cni     = "cilium"
  description = "K8s cluster Region Paris"
}

resource "scaleway_k8s_pool" "kube-par" {
  cluster_id  = scaleway_k8s_cluster.kube-par.id
  name        = "default"
  region = "fr-par"
  zone = "fr-par-1"
  node_type   = "DEV1-M"
  size        = 1
  autoscaling = false
  autohealing = false
}

resource "scaleway_k8s_cluster" "kube_ams" {
  name    = "kube_ams"
  region = "nl-ams"
  version = "1.22.1"
  cni     = "cilium"
  description = "K8s cluster Region Amsterdam"
}

resource "scaleway_k8s_pool" "kube_ams" {
  cluster_id  = scaleway_k8s_cluster.kube_ams.id
  name        = "default"
  region = "nl-ams"
  zone = "nl-ams-1"
  node_type   = "DEV1-M"
  size        = 1
  autoscaling = false
  autohealing = false
}

resource "local_file" "kubeconfig-kube-par" {
  content = scaleway_k8s_cluster.kube-par.kubeconfig[0].config_file
  filename = "${path.module}/kubeconfig-kube-par"
}

resource "local_file" "kubeconfig-kube_ams" {
  content = scaleway_k8s_cluster.kube_ams.kubeconfig[0].config_file
  filename = "${path.module}/kubeconfig-kube_ams"
}