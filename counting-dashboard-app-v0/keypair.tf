resource "tls_private_key" "counting-dashboard-key" {
  algorithm = "ED25519"
}

locals {
  private_key_filename = "${var.prefix}-ssh-key.pem"
}

resource "aws_key_pair" "counting-dashboard-keypair" {
  key_name   = local.private_key_filename
  public_key = tls_private_key.counting-dashboard-key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.counting-dashboard-key.private_key_openssh
  filename        = local.private_key_filename
  file_permission = "0400"
}