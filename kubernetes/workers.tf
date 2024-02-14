## To use template_file, you will need to use template provider

locals {
  #cluster_name         = var.cluster_name
  #cluster_prefix       = var.cluster_prefix
  worker_instance_type = var.worker_instance_type
  worker_instance_name = var.worker_instance_name  
  worker_keypair       = var.keypair_name
  #worker_name          = var.worker_instance_name
  number_of_workers    = var.number_of_workers
}

#   # You can put some variable here to render
# }

module "workers" {
  source = "../modules/ec2"  
  ami = data.aws_ami.ubuntu_ami.id
  bootstrap_script = templatefile("../scripts/templatescript.tftpl", {
    script_list : [      
      templatefile("../scripts/k8s/install-core-components.sh", {}),
      templatefile("../scripts/k8s/join-worker.sh", {}),      
    ]
  })
  cluster_prefix = local.cluster_prefix
  security_group_ids = [ module.sg_public_ssh_http_https.securitygroup_id, module.sg_nodeport_k8snodes.securitygroup_id, module.sg_kubernetes_cores.securitygroup_id, module.sg_k8s_cluster_inside.securitygroup_id ]
  keypair_name        = local.worker_keypair
  instance_type       = local.worker_instance_type
  name                = "${local.cluster_prefix}_${local.worker_instance_name}"
  number_of_instances = local.number_of_workers
  ec2_role = aws_iam_role.k8s-node-role.name
}

#This is to set ec2's hostname same as ec2 instance name in web-console
resource "aws_ssm_parameter" "k8s_worker_hostname" {
  count = local.number_of_workers
  name = element(module.workers.instance_private_ips, count.index)
  type      = "String"
  value     = "${local.cluster_prefix}-${local.worker_instance_name}-${count.index + 1}"
  overwrite = true
}