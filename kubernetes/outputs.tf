output "control_plane_public_ip" {
  #value = module.control_plane.instance[*].public_ip
  value = module.control_plane.instance[*].public_ip
}

output "worker_node_public_ip" {
  #value = module.control_plane.instance[*].public_ip
  value = module.workers.instance[*].public_ip
}


