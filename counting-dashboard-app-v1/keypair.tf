resource "tls_private_key" "main" {
  algorithm = "ED25519"
}

locals {
  private_key_filename = "${var.project_name}-ssh-key.pem"
}

resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-keypair"
  public_key = tls_private_key.main.public_key_openssh

  tags = {
    Name    = "${var.project_name}-keypair"
    Project = var.project_name
  }
}

# Save private key to local directory with 0400 permissions
resource "local_file" "private_key" {
  content         = tls_private_key.main.private_key_openssh
  filename        = "${path.module}/${local.private_key_filename}"
  file_permission = "0400"
}
