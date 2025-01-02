terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.69"
    }
    macaddress = {
      source  = "ivoronin/macaddress"
      version = "0.3.2"
    }
  }
}
