variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "name" {
  description = "EC2 instance Name tag"
  type        = string
}

variable "key_name" {
  description = "KEY NAME where EC2 will be uses to connect"
  type        = string
}
variable "sg_id"{
  description = "sg id where EC2 will be uses to connect"
  type        = string
}
