variable "ami" {
  description = "AMI para la instancia EC2"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
}

variable "subnet_id" {
  description = "ID de la subred donde se creará la instancia"
  type        = string
}

variable "security_group_id" {
  description = "ID del grupo de seguridad"
  type        = string
}
variable "region" {
  description = "Region de AWS"
  type        = string
}
variable "ecr_repository_uri" {
  description = "Repository URI AMI"
  type        = string
}