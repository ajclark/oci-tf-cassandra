# oci-tf-cassandra-cluster

## Introduction
This terraform configuration provisions the following resources:
Cassandra ARM Cluster: `30 x VM.Standard.A1.Flex.8-64`
Cassandra AMD Cluster: `30 x VM.Standard.E4.Flex-4-64`
Cassandra Stress Node Fleet: `30 x VM.Standard.A1.Flex-8-64`

## Prerequisites / assumptions
* An existing VCN with a single subnet should be already present in the target tenancy. This should be a public subnet and instances are automatically given public IPs.

## OCI Cli Setup
A functioning OCI cli setup is required on the machine you plan to run terraform commands. You should be able to execute oci cli commands e.g. `oci compute image list --all --output table` 

Example ~/.oci/config file
```
[DEFAULT]
user=ocid1.user.oc1..abc123
fingerprint=abc123
tenancy=ocid1.tenancy.oc1..abc123
region=us-ashburn-1
key_file=/Users/jsmith/.oci/joe.smith-06-21-18-04.pem
```

Example ~/.oci/oci_cli_rc file
```
[DEFAULT]
compartment-id=ocid1.compartment.oc1..aaaaaaaa4cv2fsc3qf5sq6ub2aazk5fz37t35b3syjkbvdnp5umiimemhtla
```

## Terraform layout explanation
`compute_arm.tf` - Cassandra ARM compute/block OCI configuration
`compute_amd.tf` - Cassandra AMD compute/block OCI configuration
`compute_cassandra_stress.tf` - Cassandra stress node fleet OCI configuration
`variables.tf` — OCI image IDs, subnet ids, vcn ids, tenancy ids, ssh_key ids, etc. 
`security_groups.tf` — network security group configuration


## Terraform setup
1) Follow the instructions https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli here to get started. I recommend you manually provision an Ubuntu Linux box as a quick way to get started. 
2) Git clone this repo
3) Update the properties in `variables.tf` ensuring your vcn, subnet, ssh_key and all other properties are configured to your specific tenancy, including compartment_id. If you're using the root compartment I believe you can set tenancy_id and compartment_id to be identical.
4) Ensure your public ssh key is readable by terraform and set in `variables.tf` — this will be the key that is provisioned on all nodes.
5) Update `provider.tf` to add the path to your OCI API key pem file


## Provision resources
```
terraform init # one time initialization
terraform plan
terraform apply
```

Your infrastructure should begin provisioning. To destroy the infrastructure use `terraform destroy`. If you encounter errors check the tenancy resource limits. Note that the terraform instances provision within 1-3 minutes but the `bootstrap-oraclelinux.sh` may take 5-10 minutes because of the Cassandra bootstrapping and thus a full `dnf update`. Commenting out the `dnf` lines will speed up the bootstrap process. 
You can `tail -100f /var/log/cloud-init-output.log` to follow the bootstrap process. 

## Compute Instances
All instance shape properties are stored within their respective `compute_*.tf` file. They can be modified as needed.

## Block Storage
Both clusters are configured with 2 x 2TB block storage volumes with 20 VPUs each. These volumes are automatically configured and mounted for use via `bootstrap-oraclelinux.sh` as XFS filesystems under `/mnt/data` and `/mnt/commit` respectively. The mount properties can be configured in `bootstrap-oraclelinux.sh` as required. 

Block storage properties (VPUs, GB sizes) can be modified in their respective `compute_*.tf` files. e.g. `compute_arm.tf` for the ARM cluster.

## Network Security Groups
For simplicty, all compute instances are part of a single network security group that allows all ports/all traffic from members. In the event that this causes both AMD and ARM nodes to discover each-other and form a single giant cluster modify `security_groups.tf` to create two distinct NSGs for both `_arm` and `_amd`. There is a commented out resource present to facilitate. Update `compute*tf` to reflect the NSG changes. The cassandra stress nodes should be made members of both security groups — this is done in `compute*.tf` (nsg_ids array)

Note depending on if your VNC has a default security list rule of "Allow SSH from `0.0.0.0/0` you may need to add an NSG rule to allow your office/wfh/bastion /32 CIDR to access ssh. A helper rule exists in `security_groups.tf` to facilitate this. 

## Cassandra boostrapping
The `bootstrap-oraclelinux.sh` installs and starts Cassandra by default. You can comment out the relevant `dnf install` lines in the bootstrap script if you prefer to install cassandra another way.
