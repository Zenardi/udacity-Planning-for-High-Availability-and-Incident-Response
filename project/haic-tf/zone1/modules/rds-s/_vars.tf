# variable "name" {}
variable "vpc_id" {}
variable "private_subnet_ids" {}
variable "primary_db_instance_arn" {}
variable "db_count" {
  default = 2
}