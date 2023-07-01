resource "oci_core_volume" "cassandra_data_arm" {
  count = var.arm_node_count
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "Cassandra Data Volume - ${count.index}"
  size_in_gbs         = 2048
  vpus_per_gb         = 20
}

resource "oci_core_volume" "cassandra_commit_arm" {
  count = var.arm_node_count
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "Cassandra Commit Volume - ${count.index}"
  size_in_gbs         = 2048
  vpus_per_gb         = 20
}

resource "oci_core_instance" "cassandra_instance_arm" {
  count = var.arm_node_count
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.A1.Flex"
  shape_config {
    memory_in_gbs = 64
    ocpus         = 8
  }
  source_details {
    source_id   = var.aarch64_image_id
    source_type = "image"
  }

  display_name = "Cassandra Node ARM - ${count.index}"
  create_vnic_details {
    assign_public_ip = true
    subnet_id = var.subnet_id
    nsg_ids = [ 
      oci_core_network_security_group.cassandra_nsg.id 
    ]
  }
  metadata = {
    ssh_authorized_keys = file(var.ssh_key)

    # Disk mounting + Cassandra install performed by bootstrap.sh
    user_data = "${base64encode(file("./bootstrap-oraclelinux.sh"))}"
  }
}

resource "oci_core_volume_attachment" "cassandra_data_attach_arm" {
  count = var.arm_node_count
  depends_on = [oci_core_instance.cassandra_instance_arm, oci_core_volume.cassandra_data_arm]
  attachment_type = "paravirtualized"
  compartment_id = var.compartment_id
  instance_id    = oci_core_instance.cassandra_instance_arm[count.index].id
  volume_id      = oci_core_volume.cassandra_data_arm[count.index].id
}

resource "oci_core_volume_attachment" "cassandra_commit_attach_arm" {
  count = var.arm_node_count
  depends_on = [oci_core_instance.cassandra_instance_arm, oci_core_volume.cassandra_commit_arm]
  attachment_type = "paravirtualized"
  compartment_id = var.compartment_id
  instance_id    = oci_core_instance.cassandra_instance_arm[count.index].id
  volume_id      = oci_core_volume.cassandra_commit_arm[count.index].id
}
