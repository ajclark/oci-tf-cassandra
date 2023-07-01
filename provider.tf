provider "oci" {
  auth = "APIKey"
  config_file_profile = "DEFAULT"
  region = "us-ashburn-1"
  private_key_path = "/root/my-oci-api-key.pem"
}
