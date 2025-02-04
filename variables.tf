/**
* Proxmox related configuration.
*/
variable "pve_default_node" {
  type        = string
  description = "Default Node to use for proxmox interactions"
  default     = "pve"
}

variable "pve_default_datastore_id" {
  type        = string
  description = "Default datastore to use"
  default     = "local"
}

variable "pve_default_timezone" {
  type = string
  description = "Timezone to use for vms"
  default     = "Europe/Berlin"
}

variable "dns_configuration" {
  description = "DNS config for VMs"
  type = object({
    domain  = string
    servers = list(string)
  })
}

/**
* User Configuration in VM
*/ 
variable "vm_user" {
  type = string
  sensitive = true
  description = "User name to use for vm access."
}

variable "vm_user_password" {
  type = string
  sensitive = true
  description = "User password to set automatically. Generate a sha256sum obfuscated password."
}

variable "vm_user_public_key" {
  type = string
  description = "Public key for user account to use"
}

/**
* Debian related configuration
*/
variable "debian_primary_mirror" {
  type = string
  default = "https://deb.debian.org/debian"
  description = "Default mirror to use in cloud init configuration for pulling packages."
}

variable "debian_primary_security_mirror" {
  type = string
  default = "http://security.debian.org/debian-security/"
  description = "Default security mirror to use in cloud init configuration for pulling packages."
}

/**
* OS Image configuration to use in kubernetes deployments.
* Defaults are just a example pick. Please update accordingly.
* It is adviced to use a network attached storage as datastore to provide image to all nodes in proxmox cluster.
*/
variable "os_images" {
  type = list(object({
    name               = string
    filename           = string
    url                = string
    checksum           = string
    checksum_algorithm = string
    datastore_id       = string
  }))
  default = [{
    name               = "amd64"
    filename           = "kubernetes-debian-12-generic-amd64-20240507-1740.img"
    url                = "https://cloud.debian.org/images/cloud/bookworm/20240507-1740/debian-12-generic-amd64-20240507-1740.qcow2"
    checksum           = "f7ac3fb9d45cdee99b25ce41c3a0322c0555d4f82d967b57b3167fce878bde09590515052c5193a1c6d69978c9fe1683338b4d93e070b5b3d04e99be00018f25"
    checksum_algorithm = "sha512"
    datastore_id       = "local"
    },
    {
      name               = "arm64"
      filename           = "kubernetes-debian-12-generic-arm64-20240507-1740.img"
      url                = "https://cloud.debian.org/images/cloud/bookworm/20240507-1740/debian-12-generic-arm64-20240507-1740.qcow2"
      checksum           = "626a4793a747b334cf3bc1acc10a5b682ad5db41fabb491c9c7062001e5691c215b2696e02ba6dd7570652d99c71c16b5f13b694531fb1211101d64925a453b8"
      checksum_algorithm = "sha512"
      datastore_id       = "local"
    }
  ]
}

/**
* Postgresql configuration.
*/
variable "postgres_vm_id" {
  type        = number
  default     = 10100
  description = "VM ID in proxmox to use for postgresql database."
}

variable "postgres_vm_name" {
  type        = string
  default     = "kubernetes-postgresql-backend"
  description = "VM name for postgresql vm."
}

variable "postgres_vm_node" {
  type = string
  nullable = true
  description = "Node to provision vm towards. This variable is nullable."
}

variable "postgres_vm_description" {
  type        = string
  default     = "A database as kubernetes backend used by kine."
  description = "Description for vm in proxmox."
}

variable "postgresql_vm_tags" {
  description = "VM tags for proxmox."
  type = object({
    tags = list(string)
  })
  default = {
    tags = ["kubernetes", "postgresql", "kine"]
  }
}

variable "postgres_vm_cpu_core_count" {
  type        = number
  default     = 4
  description = "core count for proxmox postgresql vm."
}

variable "postgres_vm_memory_count" {
  type        = number
  default     = 2048
  description = "memory amount in mb for postgres vm."
}

variable "postgres_vm_disk_efi_datastore_id" {
  type        = string
  nullable    = true
  description = "Datastore to use for efi disk in proxmox cloud init environment."
}

variable "postgres_vm_disk_datastore_id" {
  type        = string
  nullable    = true
  description = "Datastore to use for system disk in proxmox cloud init environment."
}

variable "postgres_vm_disk_size" {
  type        = number
  nullable    = true
  description = "Disk size of vm"
}

variable "postgres_vm_arch" {
  type        = string
  default     = "amd64"
  description = "System architecture to use for vm."
}

variable "postgres_vm_ipv4" {
  type        = string
  description = "IPv4 of postgresql vm."
}