#Update hostname before join cluster
TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

privateip=$(curl -sH "X-aws-ec2-metadata-token: $TOKEN" \
  "http://169.254.169.254/latest/meta-data/local-ipv4")

echo "Private IP: $privateip"

hostname=$(aws ssm get-parameter --name $privateip --output text --query "Parameter.Value")

echo "hostname: $hostname"
sudo hostnamectl set-hostname $hostname
clusterPrefix=$(aws ssm get-parameter --name $privateip-cluster-prefix --output text --query "Parameter.Value")

while true
do
sleep 5s
result=$(aws ssm get-parameter --name "$clusterPrefix-join-cluster" --output text --query "Parameter.Value")
echo $result
if [[ "$result" == *"kubeadm join"* ]]; then
  echo "Cluster created. Now joining worker node to cluster"
  break
fi
done


#Join cluster
sudo $(aws ssm get-parameter --name "$clusterPrefix-join-cluster" --output text --query "Parameter.Value" | sed -e "s/\\\\//g")
