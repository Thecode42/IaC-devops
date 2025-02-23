variable "region" {
  description = "Region de AWS"
  default     = "us-east-2"
}
variable "instance_type" {
  description = "Tipo de instancia EC2"
  default     = "t2.micro"
}
variable "zone_a" {
  description = "Zona disponible a"
  default     = "us-east-2a"
}

variable "zone_b" {
  description = "Zona disponible b"
  default     = "us-east-2b"
}

variable "ami_base" {
  description = "Imageb base"
  default     = "ami-07f463d9d4a6f005f"
}

variable "desired_capacity" {
  description = "Numero deseado de instancias en el Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximo número de instancias en el Auto Scaling Group"
  type        = number
  default     = 4
}

variable "min_size" {
  description = "Minimo número de instancias en el Auto Scaling Group"
  type        = number
  default     = 1
}
variable "ecr_repository_uri" {
  description = "Repository URI AMI"
  type        = string
}