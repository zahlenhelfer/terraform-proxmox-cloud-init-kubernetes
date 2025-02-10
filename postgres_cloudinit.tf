resource "proxmox_virtual_environment_file" "cloud-init-kubernetes-postgres" {
  node_name    = coalesce(var.postgres_vm_node, var.pve_default_node)
  content_type = "snippets"
  datastore_id = var.pve_default_datastore_id

  source_raw {
    data = templatefile("${path.module}/templates/postgres_cloud_init.yaml.tftpl", {
      #defaults
      hostname      = var.postgres_vm_name
      user          = var.vm_user
      user_password = var.vm_user_password
      user_pub_key  = var.vm_user_public_key
      timezone      = var.pve_default_timezone
      #apt related
      debian_primary_mirror  = var.debian_primary_mirror
      debian_primary_security_mirror = var.debian_primary_security_mirror
      #postgresql related
      postgre_admin_pw = var.postgres_conf_admin_pw
      postgre_config_address = var.postgres_conf_network_address
    })
    file_name = format("%s-%s.yaml", var.postgres_vm_id, var.postgres_vm_name)
  }
}