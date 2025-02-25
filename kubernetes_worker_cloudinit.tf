resource "proxmox_virtual_environment_file" "cloud-init-kubernetes-worker" {
  depends_on = [ module.kubeadm-join ]

  for_each = {for each in var.kubernetes_workers: each.name => each}
  node_name    = coalesce(each.value.node, var.pve_default_node)
  content_type = "snippets"
  datastore_id = var.pve_default_snippet_datastore_id

  source_raw {
    data = templatefile("${path.module}/templates/kubernetes_worker.yaml.tftpl", {
      #defaults
      hostname      = each.value.name
      user          = var.vm_user
      user_password = var.vm_user_password
      user_pub_key  = var.vm_user_public_key
      timezone      = var.pve_default_timezone
      arch = var.kubernetes_vm_worker_arch
      #apt related
      debian_primary_mirror  = var.debian_primary_mirror
      debian_primary_security_mirror = var.debian_primary_security_mirror
      #kubernetes related
      kubernetes_version = var.kubernetes_version
      kubernetes_version_semantic = var.kubernetes_version_semantic
      kubeadm_join_cmd = module.kubeadm-join.stdout
      ip = element(split("/", each.value.ip),0)
    })
    file_name = format("%s-%s.yaml", "${var.kubernetes_vm_worker_startid + each.value.id_offset}", each.value.name)
  }
}