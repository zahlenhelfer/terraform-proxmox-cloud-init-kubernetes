terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "v0.77.1"
    }
    macaddress = {
      source  = "ivoronin/macaddress"
      version = "0.3.2"
    }
  }
}
