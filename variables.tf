variable "cluster_name" {
  type    = string
  default = "k0sctl"
}

variable "controller_count" {
  type    = number
  default = 1
}

variable "worker_count" {
  type    = number
  default = 1
}

variable "instance_type_controller" {
  default = "t2.large"
}

variable "instance_type_worker" {
  default = "t2.medium"
}

variable "region" {
  default = "ap-northeast-1"
}

variable "aws_shared_credentials_file" {
  type    = string
  default = "~/.aws/credentials"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "name" {
}
