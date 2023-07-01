variable "compartment_id" {
  type    = string
  default = "ocid1.compartment.oc1..abc123"
}

variable "vcn_id" {
  type    = string
  default = "ocid1.vcn.oc1.iad.abc123"
}

# Single subnet for all instances
variable "subnet_id" {
  type    = string
  default = "ocid1.subnet.oc1.iad.abc123"
}

# Local path to your ssh key on this machine
variable "ssh_key" {
  type    = string
  default = "/root/.ssh/id_rsa.pub"
}

# Oracle-Linux-9.1-aarch64-2023.05.24-0
variable "aarch64_image_id" {
  type    = string
  default = "ocid1.image.oc1.iad.aaaaaaaav4x4mfyhsu4ue3itv3xiq2fiuc4fhosuvumiwsup4pzaitkpvuba"
}

# Oracle-Linux-9.1-2023.05.24-0
variable "x86_image_id" {
  type    = string
  default = "ocid1.image.oc1.iad.aaaaaaaaroluyfqgznhvcuakgrr3scijpae5eyxxgfj4icr6rwemn27zy7kq"
}

variable "amd_node_count" {
  type    = number
  default = 5
}

variable "arm_node_count" {
  type    = number
  default = 5
}

variable "cassandra_stress_node_count" {
  type    = number
  default = 5
}

# Return a list of Availability Domains for a given tenancy
data "oci_identity_availability_domains" "ads" {
  # This should be set to tenancy ID
  compartment_id = "ocid1.tenancy.oc1..abc123"
}
