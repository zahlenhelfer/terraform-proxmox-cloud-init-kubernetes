resource "proxmox_virtual_environment_file" "cloud-init-kubernetes-controlplane" {
  for_each     = { for each in var.controlplanes : each.name => each }
  node_name    = each.value.node
  content_type = "snippets"
  datastore_id = var.cloud_init_configuration_datastore_id

  source_raw {
    data = templatefile("${path.module}/cloud-init/ctrl.yaml.tftpl", {
      #defaults
      hostname      = each.value.name
      user          = var.user
      user_password = var.user_password
      user_pub_key  = var.user_pub_key
      timezone      = var.cloud_init_configuration_timezone
      #apt related
      apt_mirror_primary  = var.cloud_init_configuration_apt_primary_mirror_uri
      apt_mirror_security = var.cloud_init_configuration_apt_security_mirror_uri
      #kube related
      kubernetes_version = var.kubernetes_version
      # deploy without kube-proxy
      kubeadm_cmd = "kubeadm init --skip-phases=addon/kube-proxy"

    })
    file_name = format("%s-%s.yaml", "cloud-init-kubernetes-controlplane", each.value.name)
  }
}

resource "proxmox_virtual_environment_file" "cloud-init-kubernetes-worker" {
  depends_on   = [module.kubeadm-join] #create only after control plane is done
  for_each     = { for each in var.workers : each.name => each }
  node_name    = each.value.node
  content_type = "snippets"
  datastore_id = var.cloud_init_configuration_datastore_id

  source_raw {
    data = templatefile("${path.module}/cloud-init/worker.yaml.tftpl", {
      #defaults
      hostname      = each.value.name
      user          = var.user
      user_password = var.user_password
      user_pub_key  = var.user_pub_key
      timezone      = var.cloud_init_configuration_timezone
      #apt related
      apt_mirror_primary  = var.cloud_init_configuration_apt_primary_mirror_uri
      apt_mirror_security = var.cloud_init_configuration_apt_security_mirror_uri
      #kube related
      kubernetes_version = var.kubernetes_version
      kubeadm_cmd        = module.kubeadm-join.stdout
    })
    file_name = format("%s-%s.yaml", "cloud-init-kubernetes-worker", each.value.name)
  }
}
