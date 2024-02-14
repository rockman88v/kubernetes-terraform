echo "#############################"
echo "install-ebs-storageclass.sh"

#install Amazon Elastic Block Store (EBS) CSI driver
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.27"

sudo tee -a /home/ubuntu/storageclass.yaml > /dev/null << EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-storageclass
provisioner: ebs.csi.aws.com
volumeBindingMode: Immediate
parameters:
  type: gp2
allowedTopologies:
- matchLabelExpressions:
  - key: topology.ebs.csi.aws.com/zone
    values:
    - EC2_AZ
EOF

ec2_az=$(aws ssm get-parameter --name ec2_az --output text --query "Parameter.Value")
sed -i "s/EC2_AZ/$ec2_az/g" /home/ubuntu/storageclass.yaml
echo "storageclass.yaml"
cat /home/ubuntu/storageclass.yaml
#create storage class 
kubectl apply -f /home/ubuntu/storageclass.yaml