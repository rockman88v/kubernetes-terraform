echo "#############################"
echo "install-argocd.sh"

helm repo add argocd https://argoproj.github.io/argo-helm
helm repo update

cat << FOE >> ./argocd.viettq.yaml
## Argo Configs
configs:
  cm:
    exec.enabled: false  
    admin.enabled: true
    resource.customizations: |
      networking.k8s.io/Ingress:
          health.lua: |
            hs = {}
            hs.status = "Healthy"
            return hs
  params:    
    create: true
    server.insecure: true
  repositories:
    platform-app-repo:
      url: https://github.com/rockman88v/kubernetes-platform-apps.git

## Server
server:
  ingress:
    enabled: true
    controller: generic
    ingressClassName: "nginx"
    hostname: argocd.viettq.com
    path: /
    pathType: Prefix
    tls: false
FOE

echo "helm -n argocd upgrade --install argocd -f ./argocd.viettq.yaml argocd/argo-cd --version 6.0.6 --create-namespace"
helm -n argocd upgrade --install argocd -f ./argocd.viettq.yaml argocd/argo-cd --version 6.0.6 --create-namespace
