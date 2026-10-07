resource "aws_instance" "sonar_vm" {
  ami           = "ami-0f5ee92e2d63afc18" # Amazon Linux 2023 (replace with region-specific AMI)
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.devops_subnet.id
  vpc_security_group_ids = [aws_security_group.sonar_sg.id]
  key_name      = "sonar-key"
  tags = { Name = "sonarqube-server" }
}

resource "aws_instance" "jenkins_vm" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.devops_subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name      = "jenkins-key"
  tags = { Name = "jenkins-server" }
}

resource "aws_instance" "ansible_vm" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.devops_subnet.id
  vpc_security_group_ids = [aws_security_group.ansible_sg.id]
  key_name      = "ansible-key"
  tags = { Name = "ansible-server" }
}

resource "aws_instance" "terraform_vm" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.devops_subnet.id
  vpc_security_group_ids = [aws_security_group.terraform_sg.id]
  key_name      = "terraform-key"
  tags = { Name = "terraform-server" }
}
