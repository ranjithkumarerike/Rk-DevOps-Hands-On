resource "aws_security_group" "sonar_sg" {
  name   = "sonar-sg"
  vpc_id = aws_vpc.devops_vpc.id

  ingress { from_port=22; to_port=22; protocol="tcp"; cidr_blocks=["0.0.0.0/0"] }
  ingress { from_port=9000; to_port=9000; protocol="tcp"; cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_security_group" "jenkins_sg" {
  name   = "jenkins-sg"
  vpc_id = aws_vpc.devops_vpc.id

  ingress { from_port=22; to_port=22; protocol="tcp"; cidr_blocks=["0.0.0.0/0"] }
  ingress { from_port=8080; to_port=8080; protocol="tcp"; cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_security_group" "ansible_sg" {
  name   = "ansible-sg"
  vpc_id = aws_vpc.devops_vpc.id

  ingress { from_port=22; to_port=22; protocol="tcp"; cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_security_group" "terraform_sg" {
  name   = "terraform-sg"
  vpc_id = aws_vpc.devops_vpc.id

  ingress { from_port=22; to_port=22; protocol="tcp"; cidr_blocks=["0.0.0.0/0"] }
}
