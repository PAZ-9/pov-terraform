# -------------------------------------------------------
# Dashboard EC2 Instance (public subnet)
# -------------------------------------------------------
resource "aws_instance" "dashboard" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  key_name                    = aws_key_pair.main.key_name
  vpc_security_group_ids      = [aws_security_group.dashboard.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/dashboard-service.sh", {
    counting_private_ip = aws_instance.counting.private_ip
  })

  user_data_replace_on_change = true

  tags = {
    Name    = "${var.project_name}-dashboard"
    Project = var.project_name
    Tier    = "public"
  }
}

# -------------------------------------------------------
# Counting EC2 Instance (private subnet)
# -------------------------------------------------------
resource "aws_instance" "counting" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private.id
  key_name                    = aws_key_pair.main.key_name
  vpc_security_group_ids      = [aws_security_group.counting.id]
  associate_public_ip_address = false

  user_data = templatefile("${path.module}/counting-service.sh", {
    db_host = aws_db_instance.main.address
    db_name = var.db_name
    db_user = var.db_username
    db_pass = random_password.db.result
  })
  user_data_replace_on_change = true

  depends_on = [aws_nat_gateway.main, aws_db_instance.main]

  tags = {
    Name    = "${var.project_name}-counting"
    Project = var.project_name
    Tier    = "private"
  }
}

# -------------------------------------------------------
# Copy private key to dashboard instance
# -------------------------------------------------------
resource "null_resource" "copy_private_key" {
  depends_on = [aws_instance.dashboard, local_file.private_key]

  connection {
    type        = "ssh"
    host        = aws_instance.dashboard.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.main.private_key_openssh
  }

  # Ensure ~/.ssh directory exists
  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.ssh",
      "chmod 700 ~/.ssh"
    ]
  }

  # Copy private key to dashboard instance
  provisioner "file" {
    content     = tls_private_key.main.private_key_openssh
    destination = "/home/ubuntu/.ssh/${local.private_key_filename}"
  }

  # Set correct permissions on the copied key
  provisioner "remote-exec" {
    inline = [
      "chmod 400 ~/.ssh/${local.private_key_filename}",
      "echo 'Private key copied and permissions set'"
    ]
  }
}
