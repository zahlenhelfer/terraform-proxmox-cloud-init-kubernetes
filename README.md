Terraform Proxmox Cloud Init Kubernetes
===

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

This module sets up a Kubernetes cluster on a proxmox hypervisor using cloud-init for automation. It provisions the necessary nodes, deploys the kubernetes control plane and worker nodes, and configures the networking accordingly. The module assumes you have a proxmox server with an active PVE install. It does not require a prepared image and just uses the default debian cloud init image.

Getting started
---
### setup connection-infos for the provider to communicate with your proxmox-server
The easyist option is setting up environment variables for the bgp/proxmox provider. For more Authentication options, lookup the [bgp/proxmox provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs#authentication) page at registry.terraform.io.
  - set the Proxmox User-Name via `export PROXMOX_VE_USERNAME="root@pam"`
  - set the Proxmox User-Password `export PROXMOX_VE_PASSWORD=Pa$$w0rd`
  - set the URL to the Proxmox Dashboard/API-Server `export PROXMOX_VE_ENDPOINT="https://pve:8006/"`
  - Ignore TLS/SSL check if self-signed. `export PROXMOX_VE_INSECURE=true`

### create a __quickstart__ example terraform-file (`main.tf`)

```
module "kubernetes" {
  source        = "github.com/deB4SH/terraform-proxmox-cloud-init-kubernetes"
  
  # Default user to create in the vm´s
  user = "student"

  # Password-Hash for the user
  user_password = "113459eb7bb31bddee85ade5230d6ad5d8b2fb52879e00a84ff6ae1067a210d3"

  # your public key to use for authentication instead of a password
  user_pub_key  = "ssh-rsa xxx"

  # your DNS-Server that the VMs could use
  dns_configuration = {
    domain  = "."
    servers = ["192.168.178.10"]
  }

  # Gatway for the VMs
  network_gateway = "192.168.178.1"

  # the kubernetes version that should be installed (default is 1.30)
  kubernetes_version = "1.31"

  controlplanes = [
    {
      name         = "cp-0"
      ip           = "192.168.178.210/24"
      vm_cpu_cores = 4
      vm_memory    = 8192
      id_offset    = 0
    }
  ]

  workers = [
    {
      name         = "worker-0"
      ip           = "192.168.178.211/24"
      id_offset    = 10
      image_type   = "amd64"
    },
    {
      name         = "worker-1"
      ip           = "192.168.178.212/24"
      id_offset    = 11
      image_type   = "arm"
    }
  ]

}

```
### execute the code and create the cluster
- do a `terraform init` to download all necessary dependencies.
- do a `terraform apply` to create a plan and execute it against your proxmox-server.
- if you get a error-message like: `Warning: the datastore "local" does not support content type "snippets"; supported content types are: [backup iso vztmpl]` then you need to set a location for the `snippets` feature in proxmox.
An easy fix for that could be:
`pvesm set local --content images,rootdir,vztmpl,backup,iso,snippets`
- after some minutes you get your kubernetes cluster created. The necessary `config`-file is created in an `output`-folder within your terraform-project directory. You can use this `config` with your local `kubectl`:
`$ export KUBECONFIG=$(pwd)/output/config`
after that you might ask for the list of nodes in your cluster:
```
$ kubectl get nodes
NAME       STATUS     ROLES           AGE     VERSION
cp-0       NotReady   control-plane   10m     v1.30.9
worker-0   NotReady   <none>          8m23s   v1.30.9
```
A good next step would be adding a network component to your cluster. The `kubeadm init` in the script had a `--skip-phases=addon/kube-proxy`, so [Cilium](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/#install-cilium) could be a nice choice for a CNI without the need for a kube-proxy.

### destroy everything
As usual a `terraform destroy` will ask for permission and then destroy the virtual machines on your proxmox-server.

[contributors-shield]: https://img.shields.io/github/contributors/deb4sh/terraform-proxmox-cloud-init-kubernetes.svg?style=for-the-badge
[contributors-url]: https://github.com/deb4sh/terraform-proxmox-cloud-init-kubernetes/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/deb4sh/terraform-proxmox-cloud-init-kubernetes.svg?style=for-the-badge
[forks-url]: https://github.com/deb4sh/terraform-proxmox-cloud-init-kubernetes/network/members
[stars-shield]: https://img.shields.io/github/stars/deb4sh/terraform-proxmox-cloud-init-kubernetes.svg?style=for-the-badge
[stars-url]: https://github.com/deb4sh/terraform-proxmox-cloud-init-kubernetes/stargazers
[issues-shield]: https://img.shields.io/github/issues/deb4sh/terraform-proxmox-cloud-init-kubernetes.svg?style=for-the-badge
[issues-url]: https://github.com/deb4sh/terraform-proxmox-cloud-init-kubernetes/issues
[license-shield]: https://img.shields.io/github/license/deb4sh/terraform-proxmox-cloud-init-kubernetes.svg?style=for-the-badge
[license-url]: https://github.com/deb4sh/terraform-proxmox-cloud-init-kubernetes/blob/main/LICENSE.txt