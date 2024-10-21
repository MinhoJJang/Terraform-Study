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

module "s3" {
  source = "./modules/s3"
  bucket_name = "my-cdc-s3-bucket"
  force_destroy = true  # Set to true if you want to delete objects during bucket destruction
  tags = {
    Environment = "production"
    CreatedBy   = "Terraform"
  }
  versioning_enabled = true 
}

module "firehose" {
  source              = "./modules/firehose"
  name_prefix         = "my-firehose"
  s3_bucket_arn       = module.s3.bucket_arn  
  kinesis_stream_arn = module.kinesis.stream_arn 
}

output "stream_arn" {
 value = module.kinesis.stream_arn
}

output "rds_endpoint" {
 value = module.rds.rds_endpoint
}

