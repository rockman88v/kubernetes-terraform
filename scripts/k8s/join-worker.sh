while true
do
sleep 5s
result=$(aws ssm get-parameter --name k8s_join_command --output text --query "Parameter.Value")
echo $result
if [[ "$result" == *"kubeadm join"* ]]; then
  echo "Cluster created. Now joining worker node to cluster"
  break
fi
done
#Update hostname before join cluster
privateip=`hostname -i`
hostname=$(aws ssm get-parameter --name $privateip --output text --query "Parameter.Value")
sudo hostnamectl set-hostname $hostname

#Join cluster
sudo $(aws ssm get-parameter --name k8s_join_command --output text --query "Parameter.Value" | sed -e "s/\\\\//g")
