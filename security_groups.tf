#
# One big security group for all nodes.
# Note: If this provides cassandra cluster gossiping issues then uncomment the additional security group below
#       and attach an amd nsg to amd compute and arm nsg to arm compute. Make cassandra stress nodes a member
#       of both.
#
# You may also want to add a rule for your office/home/bastion for ssh access to nodes
#

resource "oci_core_network_security_group" "cassandra_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "Cassandra Security Group"
}

resource "oci_core_network_security_group_security_rule" "cassandra_client_ports" {
  network_security_group_id = oci_core_network_security_group.cassandra_nsg.id
  description = "Cassandra Client Ports"
  direction   = "INGRESS"
  protocol    = "all"
  source_type = "NETWORK_SECURITY_GROUP"
  source      = oci_core_network_security_group.cassandra_nsg.id
}

# Add your home/office/bastion CIDR /32 here for ssh access to nodes
resource "oci_core_network_security_group_security_rule" "cassandra_ssh_access" {
  network_security_group_id = oci_core_network_security_group.cassandra_nsg.id
  description = "Cassandra SSH Access"
  direction   = "INGRESS"
  protocol    = 6
  source_type = "CIDR_BLOCK"
  source      = "198.51.100.10/32" # changeme
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

#resource "oci_core_network_security_group" "cassandra_nsg_amd" {
#  compartment_id = var.compartment_id
#  vcn_id         = var.vcn_id
#  display_name   = "Cassandra Security Group - AMD"
#}

#resource "oci_core_network_security_group_security_rule" "cassandra_client_ports_amd" {
#  network_security_group_id = oci_core_network_security_group.cassandra_nsg_amd.id
#  description = "Cassandra Client Ports"
#  direction   = "INGRESS"
#  protocol    = "all"
#  source_type = "NETWORK_SECURITY_GROUP"
#  source      = oci_core_network_security_group.cassandra_nsg_amd.id
#}

