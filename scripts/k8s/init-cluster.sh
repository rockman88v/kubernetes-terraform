echo "#############################"
echo "init-cluster.sh"
#Update hostname before init cluster
sudo hostnamectl set-hostname "master"

#init cluster
sudo kubeadm init --ignore-preflight-errors=NumCPU,Mem --v=5 --cri-socket=unix:///var/run/containerd/containerd.sock

#Update kubeconfig file to use kubectl
mkdir -p /home/ubuntu/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown -R ubuntu:ubuntu /home/ubuntu/.kube/

#Update hostname before join cluster
privateip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
clusterPrefix=$(aws ssm get-parameter --name $privateip-cluster-prefix --output text --query "Parameter.Value")


##### update k8s_join_command param
aws ssm put-parameter --name="$clusterPrefix-join-cluster"  --type=String --value="$(cat /var/log/cloud-init-output.log | grep 'kubeadm join' -A1)" --overwrite

# Install calico CNI
echo "============Install Calico CNI ============"

max_attempts=60  # Total waiting time: 60 * 5 seconds = 5 minutes
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if kubectl --kubeconfig /home/ubuntu/.kube/config get nodes &> /dev/null; then
        echo "kubectl get nodes succeeded."
        kubectl --kubeconfig /home/ubuntu/.kube/config apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
        break
    else
        echo "attempt=$attempt: kubernetes cluster is not ready yet..."
        sleep 10
        ((attempt++))
    fi
done



