resource "macaddress" "k8s-ctrl-mac" {} #generate a fresh random mac address

resource "proxmox_virtual_environment_vm" "k8s-ctrl" {
  depends_on    = [macaddress.k8s-ctrl-mac]
  for_each      = { for each in var.controlplanes : each.name => each }
  node_name     = each.value.node
  name          = each.value.name
  description   = var.vm_description
  tags          = var.vm_tags.tags
  on_boot       = true
  vm_id         = var.vm_id + each.value.id_offset
  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  bios          = "ovmf"

  cpu {
    cores = each.value.vm_cpu_cores
    type  = "host"
  }

  memory {
    dedicated = each.value.vm_memory
  }

  network_device {
    bridge      = "vmbr0"
    mac_address = macaddress.k8s-ctrl-mac.address
  }

  efi_disk {
    datastore_id = var.vm_datastore_id
    file_format  = "raw" // To support qcow2 format
    type         = "4m"
  }

  disk {
    datastore_id = var.vm_datastore_id
    file_id      = proxmox_virtual_environment_download_file.image[each.value.image_type].id
    interface    = "scsi0"
    cache        = "writethrough"
    discard      = "on"
    ssd          = true
    size         = 32
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
        gateway = var.vm_ip_config.gateway
      }
    }

    datastore_id      = var.vm_datastore_id
    user_data_file_id = proxmox_virtual_environment_file.cloud-init-kubernetes-controlplane[each.value.name].id
  }
}
