echo "#############################"
echo "install-ingress-controller.sh"
helm repo add  nginx-stable https://helm.nginx.com/stable
helm repo update

cat << FOE >> ./ingress-controller.viettq.yaml
controller:
  ingressClass:  
    name: nginx
    create: true
    setAsDefaultIngress: true
  service:
    create: true
    type: NodePort
    externalTrafficPolicy: Cluster    
    httpPort:
      enable: true
      port: 80
      nodePort: 30080
      targetPort: 80
    httpsPort:
      enable: true
      port: 443
      nodePort: 30443
      targetPort: 443 
FOE
echo "helm -n ingress-controller install ingress-controller -f ./ingress-controller.viettq.yaml nginx-stable/nginx-ingress --version 1.1.2 --create-namespace"
helm -n ingress-controller install ingress-controller -f ./ingress-controller.viettq.yaml nginx-stable/nginx-ingress --version 1.1.2 --create-namespace
