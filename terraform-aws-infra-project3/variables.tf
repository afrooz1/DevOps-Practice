variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "tf-project3"
}

variable "ami_id" {
  default = "ami-0ffd8e96d1336b6ac"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  default = "terraform-key"
}