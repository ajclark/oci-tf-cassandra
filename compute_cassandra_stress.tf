resource "oci_core_instance" "cassandra_instance_stress" {
  count = var.cassandra_stress_node_count
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.E4.Flex"
  shape_config {
    memory_in_gbs = 64
    ocpus         = 4
  }
  source_details {
    source_id   = var.x86_image_id
    source_type = "image"
  }

  display_name = "Cassandra Stress Node AMD - ${count.index}"
  create_vnic_details {
    assign_public_ip = true
    subnet_id = var.subnet_id
    
    # Stress nodes can access both NSGs
    nsg_ids = [ 
      oci_core_network_security_group.cassandra_nsg.id
      #oci_core_network_security_group.cassandra_nsg_amd.id,
      #oci_core_network_security_group.cassandra_nsg_arm.id
    ]
  }
  metadata = {
    ssh_authorized_keys = file(var.ssh_key)

    # Disk mounting + Cassandra install performed by bootstrap.sh
    user_data = "${base64encode(file("./bootstrap-oraclelinux.sh"))}"
  }
}
