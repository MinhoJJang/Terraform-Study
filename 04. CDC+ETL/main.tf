module "rds" {
  source = "./modules/rds"
  name_prefix = "my-rds" 
  username    = "admin"  
  password    = "Password123!" 
}

module "kinesis" {
  source = "./modules/kinesis"
  name_prefix = "my-kinesis"
}

module "iam" {
  source = "./modules/iam"
  name_prefix = "my-dms"
  kinesis_stream_arn = module.kinesis.stream_arn
}

module "dms_endpoints" {
  source = "./modules/dms_endpoints"

  name_prefix        = "my-dms"
  rds_endpoint       = module.rds.rds_endpoint
  rds_port          = module.rds.rds_port
  rds_username      = module.rds.username
  rds_password      = module.rds.password  
  rds_database_name = "mydb"
  kinesis_stream_arn = module.kinesis.stream_arn
dms_kinesis_access_role_arn = module.iam.dms_full_access_role_arn
}

module "dms_replication_instance" {
  source = "./modules/dms_replication_instance"
  name_prefix                 = "my-dms"
  replication_instance_class  = "dms.t3.micro" # Choose appropriate instance size
  allocated_storage           = 20
  replication_subnet_group_id = module.dms_subnet_group.id # Use subnet group from new module
  vpc_security_group_ids      = [module.dms_security_group.id] # Use security group from new module
}

module "dms_subnet_group" {
  source = "./modules/dms_subnet_group"
  name_prefix = "my-dms"
}

module "dms_security_group" {
  source = "./modules/dms_security_group"
  name_prefix = "my-dms"
}

output "stream_arn" {
 value = module.kinesis.stream_arn
}

output "rds_endpoint" {
 value = module.rds.rds_endpoint
}

