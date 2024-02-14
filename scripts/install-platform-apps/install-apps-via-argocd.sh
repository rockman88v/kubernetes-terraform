echo "#############################"
echo "install-apps-via-argocd.sh"

echo "install metric-server  by argo-app"
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: metric-server
  namespace: argocd
spec:
  destination:
    namespace: kube-system
    server: https://kubernetes.default.svc
  project: default
  source:
    helm:
      valueFiles:
      - values.yaml
    path: metric-server
    repoURL: https://github.com/rockman88v/kubernetes-platform-apps.git
    targetRevision: HEAD
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

echo "install cert-manager by argo-app"
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cert-manager
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/rockman88v/kubernetes-platform-apps.git
    path: cert-manager
    targetRevision: HEAD
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: cert-manager
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

echo "install kubernetes-dashboard by argo-app"
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: kubernetes-dashboard
  namespace: argocd
spec:
  destination:
    namespace: kubernetes-dashboard
    server: https://kubernetes.default.svc
  project: default
  source:
    directory:
      jsonnet:
        tlas:
        - name: ""
          value: ""
    path: kubernetes-dashboard
    repoURL: https://github.com/rockman88v/kubernetes-platform-apps.git
    targetRevision: HEAD
  syncPolicy:
    automated:
      prune: true
      selfHeal: true    
EOF