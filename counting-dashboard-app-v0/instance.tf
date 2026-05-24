resource "aws_instance" "dashboard-instance" {
  depends_on             = [aws_instance.counting-instance]
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.counting-dashboard-keypair.key_name
  subnet_id              = aws_subnet.dashboard-subnet.id
  vpc_security_group_ids = [aws_security_group.dashboard-sg.id]
  user_data = templatefile("${path.module}/dashboard-userdata.sh.tpl", {
    counting_ip = aws_instance.counting-instance.private_ip
  })
  tags = {
    Name       = "${var.prefix}-dashboard-instance"
    Department = "${var.department}"
  }
}

resource "aws_instance" "counting-instance" {
  depends_on = [
    aws_nat_gateway.nat
  ]
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.counting-dashboard-keypair.key_name
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.counting-subnet.id
  vpc_security_group_ids      = [aws_security_group.counting-sg.id]
  user_data                   = file("${path.module}/counting-userdata.sh")
  tags = {
    Name       = "${var.prefix}-counting-instance"
    Department = "${var.department}"
  }
}



# We're using a little trick here so we can run the provisioner without
# destroying the VM. Do not do this in production.

# If you need ongoing management (Day N) of your virtual machines a tool such
# as Chef or Puppet is a better choice. These tools track the state of
# individual files and can keep them in the correct configuration.

# Here we do the following steps:
# Sync everything in files/ to the remote VM.
# Set up some environment variables for our script.
# Add execute permissions to our scripts.
# Run the deploy_app.sh script.

# resource "null_resource" "configure-hellocloud-app" {
#   depends_on = [aws_eip_association.hellocloud]

#   triggers = {
#     build_number = timestamp()
#   }

#   provisioner "file" {
#     source      = "${path.module}/files/"
#     destination = "/home/ubuntu/"

#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = tls_private_key.counting-dashboard-key_key_pem
#       host        = aws_eip.counting-dashboard.public_ip
#     }
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt -y update",
#       "sleep 15",
#       "sudo apt -y update",
#       "sudo apt -y install apache2",
#       "sudo systemctl start apache2",
#       "sudo chown -R ubuntu:ubuntu /var/www/html",
#       "chmod +x *.sh",
#       "sudo apt -y install cowsay",
#       "cowsay Hellooooooooooo!",
#     ]

#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = tls_private_key.counting-dashboard-key.private_key_pem
#       host        = aws_eip.counting-dashboard.public_ip
#     }
#   }
# }