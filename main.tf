# # Creation of VM in AWS 
#  - Security group 

resource "aws_security_group" "allow_SSH" {
  name        = "allow_SSH1"
  description = "Allow SSH inbound traffic"

  #  - INBOUND

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  #  - OUTBOUND RULES

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

#  - key pair

resource "aws_key_pair" "deployer1" {
  key_name   = "deployer-key11"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDkYCGWXuW7c3JoKYTKbQC5hrKevkNV5pYKTHD5+421Y8D6DxQY2FcM1v4+BnOzmviAwxHFY6ucHY42IH/BST5FUeLfXZsFt9AZBE5N/cBlq+8Eiht6QnKiuU0FQ12prgdpKghLoifhNccZEkm4GCP4XUETGkdNyTPEB1f7109A7VDDaUQBhNeQ6///Z3L+2AUquXLSVAngTwfRJvFnmzjrWrRXiP/1xqMjyitSxDrV78y9um4Wknx1QH4lTbDhn/pqcIPugkv9WiV67F1ZkRLmgf8vE7yUOJvIly/joIkW67zqnq7K4S8EYBTDybwzudnmiRc61JHmuqtbl4aHAxSd ashish.ch@BBMITASHISHCH"

}
resource "aws_instance" "amzn-linux" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.deployer1.key_name
  vpc_security_group_ids = ["${aws_security_group.allow_SSH.id}"]
  tags = {
    "Name" = "Linux-Node"
    "ENV"  = "Dev"
  }

  depends_on = [aws_key_pair.deployer1]

}


####### Ubuntu VM #####


resource "aws_instance" "ubuntu" {
  ami                    = "ami-04505e74c0741db8d"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.deployer1.key_name
  vpc_security_group_ids = ["${aws_security_group.allow_SSH.id}"]
  tags = {
    "Name" = "UBUNTU-Node"
    "ENV"  = "Dev"
  }


  # Type of connection to be established
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./deployer")
    host        = self.public_ip
  }

  # Remotely execute commands to install Java, Python, Jenkins
  provisioner "remote-exec" {
    inline = [
      "sudo apt update && upgrade",
      "sudo apt install -y python3.8",
      "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
      "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ >  /etc/apt/sources.list.d/jenkins.list'",
      "sudo apt-get update",
      "sudo apt-get install -y openjdk-8-jre",
      "sudo apt-get install -y jenkins",
      "sudo apt-get install -y docker docker.io",
      "sudo chmod 777 /var/run/docker.sock",
      "sudo cat  /var/lib/jenkins/secrets/initialAdminPassword",
    ]
  }

  depends_on = [aws_key_pair.deployer1]

}