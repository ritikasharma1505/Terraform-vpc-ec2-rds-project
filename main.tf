data "aws_ssm_parameter" "rds_password" {
  name = "/prod/rds/db_password"
  with_decryption = true
}


# Call the VPC Module
module "vpc" {
  source = "./modules/vpc"

  cidr_block = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
}


resource "aws_key_pair" "ec2" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# Call the EC2 Instance Module

module "ec2" {
  source = "./modules/ec2"
  instance_type = "t2.micro"
  key_name = var.key_name                                 
  vpc_id   = module.vpc.vpc_id
  allowed_ssh_cidr = "0.0.0.0/0"
  subnet_id = module.vpc.public_subnet_ids[0]                 # Use the first public subnet

}

# Call the RDS Module

module "rds" {
  source = "./modules/rds"
  db_name = "mydb"
  username = "admin"
  password = data.aws_ssm_parameter.rds_password.value        # Secure password

  subnet_ids = module.vpc.private_subnet_ids
  vpc_security_group_ids = [module.vpc.rds_sg_id]
}
