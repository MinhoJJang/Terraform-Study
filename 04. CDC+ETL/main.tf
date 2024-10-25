module "network" {
  source          = "./modules/network"
  name_prefix     = var.name_prefix
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "rds" {
  source            = "./modules/rds"
  name_prefix       = var.name_prefix
  username          = var.rds_username
  password          = var.rds_password
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
}

module "kinesis" {
  source      = "./modules/kinesis"
  name_prefix = var.name_prefix
}

module "iam" {
  source             = "./modules/iam"
  name_prefix        = var.name_prefix
  kinesis_stream_arn = module.kinesis.stream_arn
}

module "dms_endpoints" {
  source = "./modules/dms_endpoints"

  name_prefix                 = var.name_prefix
  rds_endpoint                = module.rds.rds_endpoint
  rds_port                    = module.rds.rds_port
  rds_username                = module.rds.username
  rds_password                = module.rds.password
  kinesis_stream_arn          = module.kinesis.stream_arn
  dms_kinesis_access_role_arn = module.iam.dms_full_access_role_arn
}

module "s3" {
  source      = "./modules/s3"
  name_prefix = var.name_prefix
}

module "firehose" {
  source             = "./modules/firehose"
  name_prefix        = var.name_prefix
  s3_bucket_arn      = module.s3.bucket_arn
  kinesis_stream_arn = module.kinesis.stream_arn
}

# output "stream_arn" {
#   value = module.kinesis.stream_arn
# }

# output "rds_endpoint" {
#   value = module.rds.rds_endpoint
# }

