
/**
* OS Image configuration to use in kubernetes deployments.
* Defaults are just a example pick. Please update accordingly.
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