output "sonar_public_ip" { value = aws_instance.sonar_vm.public_ip }
output "jenkins_public_ip" { value = aws_instance.jenkins_vm.public_ip }
output "ansible_public_ip" { value = aws_instance.ansible_vm.public_ip }
output "terraform_public_ip" { value = aws_instance.terraform_vm.public_ip }
