######
# Kubernates replated commands
# - steps:
# -- 1) write vm ip to disk
# -- 2) extract kubeconf and write to disk
# -- 3) kubeadm token create for workers to join
#####

#Step 1: write ip for backup reasons to disk (required for step 3 and 4)
output "kubernetes_controlplane_root_ip" {
  depends_on = [proxmox_virtual_environment_vm.vm-k8s-kubernetes-controlplane]
  value      = proxmox_virtual_environment_vm.vm-k8s-kubernetes-controlplane[element(var.kubernetes_controlplanes,0).name].ipv4_addresses[1][0]
}
resource "local_file" "ctrl-ip" {
  content         = proxmox_virtual_environment_vm.vm-k8s-kubernetes-controlplane[element(var.kubernetes_controlplanes,0).name].ipv4_addresses[1][0]
  filename        = "output/ctrl-ip.txt"
  file_permission = "0644"
}

#Step 2: Write kubeconf to disk
module "kube-config" {
  depends_on   = [local_file.ctrl-ip]
  source       = "Invicton-Labs/shell-resource/external"
  version      = "0.4.1"
  command_unix = "ssh -o UserKnownHostsFile=/tmp/control_plane_known_host -o StrictHostKeyChecking=no ${var.vm_user}@${local_file.ctrl-ip.content} cat /home/${var.vm_user}/.kube/config"
}

resource "local_file" "kube-config" {
  content         = module.kube-config.stdout
  filename        = "output/config"
  file_permission = "0600"
}

#Step 3: kubeadm token
module "kubeadm-join" {
  depends_on   = [local_file.kube-config]
  source       = "Invicton-Labs/shell-resource/external"
  version      = "0.4.1"
  command_unix = "ssh -o StrictHostKeyChecking=no ${var.vm_user}@${local_file.ctrl-ip.content} /usr/bin/kubeadm token create --print-join-command"
}