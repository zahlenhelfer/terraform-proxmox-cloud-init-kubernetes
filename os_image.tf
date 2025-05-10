#image from here: https://cloud.debian.org/images/cloud/bookworm/daily/20240412-1715/
resource "proxmox_virtual_environment_download_file" "image" {
  for_each = { for each in var.os_images : each.name => each }

  node_name          = var.pve_default_node
  content_type       = "iso"
  datastore_id       = coalesce(var.os_images_datastore_id, var.pve_default_datastore_id)
  file_name          = each.value.filename
  url                = each.value.url
  checksum           = each.value.checksum
  checksum_algorithm = each.value.checksum_algorithm

  lifecycle {
    prevent_destroy = var.always_pull_os_images
  }
}
