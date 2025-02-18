/**
* Generate a fresh mac.
* Mostly used in selfhosted environments for dhcp ip reservation purposes.
*/
resource "macaddress" "mac-vm-kubernetes-worker" {
    for_each = {for each in var.kubernetes_workers: each.name => each}
} 

/**
* VM for kubernetes control planes.
*/
resource "proxmox_virtual_environment_vm" "vm-k8s-kubernetes-worker" {
  depends_on = [ proxmox_virtual_environment_vm.vm-k8s-kubernetes-controlplane ]
  for_each = {for each in var.kubernetes_workers: each.name => each}

  node_name     = coalesce(each.value.node, var.pve_default_node)
  name          = each.value.name
  description   = var.kubernetes_vm_worker_description
  tags          = var.kubernetes_vm_worker_tags.tags
  on_boot       = true
  vm_id         = "${var.kubernetes_vm_worker_startid + each.value.id_offset}"
  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  bios          = "ovmf"

  cpu {
    cores = coalesce(each.value.vm_cpu_count, var.kubernetes_vm_worker_cpu)
    type  = "host"
  }

  memory {
    dedicated = coalesce(each.value.vm_memory_count, var.kubernetes_vm_worker_memory)
  }

  network_device {
    bridge      = "vmbr0"
    mac_address = macaddress.mac-vm-kubernetes-worker[each.key].address
  }

  efi_disk {
    datastore_id = coalesce(each.value.disk_datastore_id, var.pve_default_datastore_id)
    file_format  = "raw" // To support qcow2 format
    type         = "4m"
  }

  disk {
    datastore_id = coalesce(each.value.disk_datastore_id, var.pve_default_datastore_id)
    file_id      = proxmox_virtual_environment_download_file.image[coalesce(each.value.os_image_type, var.kubernetes_vm_worker_arch)].id
    interface    = "scsi0"
    cache        = "writethrough"
    discard      = "on"
    ssd          = true
    size         = coalesce(var.kubernetes_vm_worker_disk_size, 32)
  }

  /**
  * FIX: seems to be requiered by debain 12 as is requests a serial_device on socket 0
  * REF: https://www.reddit.com/r/Proxmox/comments/1gujajr/comment/lxvzbk6/
  */
  serial_device {
    device = "socket"
  }

  boot_order = ["scsi0"]

  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }

  initialization {
    dns {
      domain  = var.dns_configuration.domain
      servers = var.dns_configuration.servers
    }
    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = coalesce(each.value.gateway, var.pve_network_default_gateway)
      }
    }

    datastore_id      = each.value.disk_datastore_id
    user_data_file_id = proxmox_virtual_environment_file.cloud-init-kubernetes-worker[each.key].id
  }
}