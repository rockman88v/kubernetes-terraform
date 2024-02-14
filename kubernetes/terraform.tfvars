cluster_prefix                = "viettq"
keypair_name                = "viettq-key"
master_instance_type        = "t3.small"
worker_instance_type        = "t3.small"
master_instance_name        = "master"
worker_instance_name        = "worker"
region                      = "ap-southeast-1"
number_of_workers           = "2"

included_components         = ["haproxy", "argocd", "ingress-controller", "ebs-storageclass", "platform-app"]
# haproxy           : Install haproxy on master node and setup rule to kubernete ingress backend
# argocd            : Install argocd on installed kubernetes cluster using helm-chart
# ingress-controller: Install ingress-controller on installed kubernetes cluster using helm-chart
# ebs-storageclass  : Install storageclass using ebs volume on installed kubernetes cluster
# platform-app      : Install platform app by create argocd app and sync to kubernetes cluster. Currently include metric-server, cert-manager, kubernetes-dashboard
