provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
  ecr_repository_uri = var.ecr_repository_uri

}
# module "ec2" {
#   source = "./modules/ec2"

#     ami                    = "ami-07f463d9d4a6f005f"
#     instance_type          = var.instance_type
#     subnet_id              = module.vpc.public_subnet1_id
#     security_group_id      = module.vpc.security_group_id
#     region                 = var.region
#     ecr_repository_uri     = var.ecr_repository_uri
# }