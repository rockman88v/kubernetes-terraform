### master.tf
data "aws_ami" "ubuntu_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_iam_policy" "EBSCSIDriverPolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role" "k8s-node-role" {

  name = "${local.cluster_prefix}_role"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  /* This policy need attaching to  */
  inline_policy {
    name = "access_parameter_store"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "ssm:PutParameter",
            "ssm:LabelParameterVersion",
            "ssm:DeleteParameter",
            "ssm:UnlabelParameterVersion",
            "ssm:DescribeParameters",
            "ssm:RemoveTagsFromResource",
            "ssm:GetParameterHistory",
            "ssm:AddTagsToResource",
            "ssm:GetParametersByPath",
            "ssm:GetParameters",
            "ssm:GetParameter",
            "ssm:DeleteParameters"
          ],
          "Resource" : "*" // TODO: This will need to be more specific to secure, but just keep it simple for now
        },
      ]
    })
  }

  tags = {
    Name = "k8s-node-role"
  }
}

resource "aws_iam_role_policy_attachment" "EBSCSIDriver-policy-attach" {
  #count = local.include_ebs_csi_driver_policy ? 1 : 0
  count = 1
  #role  = aws_iam_role.control_plane_role.name
  role = aws_iam_role.k8s-node-role.name
  # NOTE: This policy should be attached to Nodes which need to create EBS
  # Because this script is using control_plane_role for both control_plane and worker
  # -> Attach to this role
  policy_arn = local.ebs_csi_driver_policy_arn
}


module "control_plane" {
  source = "../modules/ec2"
  ami    = data.aws_ami.ubuntu_ami.id
  
  bootstrap_script = templatefile("../scripts/templatescript.tftpl", {
    script_list : [
      contains(local.included_components, "haproxy") ? templatefile("../scripts/haproxy/install-haproxy.sh", {}) : "",      
      templatefile("../scripts/k8s/install-core-components.sh", {}),
      templatefile("../scripts/k8s/init-cluster.sh", {}),      
      templatefile("../scripts/k8s/configure-kubectl.sh", {}),
      contains(local.included_components, "argocd") ? templatefile("../scripts/install-platform-apps/install-argocd.sh", {}) : "",
      contains(local.included_components, "ingress-controller") ? templatefile("../scripts/install-platform-apps/install-ingress-controller.sh", {}) : "",
      contains(local.included_components, "ebs-storageclass") ? templatefile("../scripts/install-platform-apps/install-ebs-storageclass.sh", {}) : "",
      contains(local.included_components, "platform-app") ? templatefile("../scripts/install-platform-apps/install-apps-via-argocd.sh", {}) : "",    
    ]
  })


  #role = aws_iam_role.k8s-node-role.name
  ec2_role = aws_iam_role.k8s-node-role.name
  security_group_ids = [ module.sg_public_ssh_http_https.securitygroup_id, module.sg_nodeport_k8snodes.securitygroup_id, module.sg_kubernetes_cores.securitygroup_id, module.sg_k8s_cluster_inside.securitygroup_id ]
  keypair_name       = local.keypair_name
  instance_type      = local.master_instance_type 
  name               = "${local.cluster_prefix}_${local.master_instance_name}"
  cluster_prefix     = local.cluster_prefix
}

#This is to add cluster-prefix for the cluster-join-command so we can create multiple cluster at the same time without any overrides
#This SSM Param is set in the bootstrap script in master node after init the k8s cluster
resource "aws_ssm_parameter" "cluster_join" {  
  name = "${local.cluster_prefix}-join-cluster"
  type      = "String"
  value     = "NULL"
  overwrite = true
}

#The cluster-prefix is broadcast to all nodes by setting a SSM Param as the format: privateIP-cluster-prefix
#So that from every node can get this SSM Param because it know its private IP
resource "aws_ssm_parameter" "k8s_master_cluster_info" {  
  name      = "${module.control_plane.instance_private_ips[0]}-cluster-prefix"
  type      = "String"
  value     = "${local.cluster_prefix}"
  overwrite = true
}