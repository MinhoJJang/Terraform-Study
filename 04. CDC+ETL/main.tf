module "network" {
  source          = "./modules/network"
  name_prefix     = var.name_prefix
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "iam" {
  source      = "./modules/iam"
  name_prefix = var.name_prefix
}

module "security_group" {
  source      = "./modules/security_group"
  name_prefix = var.name_prefix
  vpc_id      = module.network.vpc_id
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
  source      = "./modules/kinesis_streams"
  name_prefix = var.name_prefix
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
  firehose_role_arn  = module.iam.firehose_role_arn
}

module "dms_subnet_group" {
  source      = "./modules/dms_subnet_group"
  name_prefix = var.name_prefix
  vpc_id      = module.network.vpc_id
  subnet_ids  = module.network.public_subnet_ids
}

module "dms_endpoints" {
  source = "./modules/dms_endpoints"

  name_prefix        = var.name_prefix
  rds_endpoint       = module.rds.rds_endpoint
  rds_port           = module.rds.rds_port
  rds_username       = module.rds.username
  rds_password       = module.rds.password
  kinesis_stream_arn = module.kinesis.stream_arn
  dms_role_arn       = module.iam.dms_role_arn
}

module "dms_instance" {

  source                      = "./modules/dms_instance"
  name_prefix                 = var.name_prefix
  replication_subnet_group_id = module.dms_subnet_group.dms_replication_subnet_group_id
  vpc_security_group_ids      = [module.security_group.security_group_id]
}

module "dms_task" {
  source                   = "./modules/dms_task"
  name_prefix              = var.name_prefix
  replication_instance_arn = module.dms_instance.replication_instance_arn
  source_endpoint_arn      = module.dms_endpoints.dms_source_endpoint_arn
  target_endpoint_arn      = module.dms_endpoints.dms_target_endpoint_arn
  table_mappings = jsonencode({
    rules = [
      {
        rule-type = "selection"
        rule-id   = "1"
        rule-name = "1"
        object-locator = {
          schema-name = "%"
          table-name  = "%"
        }
        rule-action = "include"
      }
    ]
  })

  replication_task_settings = jsonencode({
    TargetMetadata = {
      SupportLobs        = true
      FullLobMode        = true
      LobChunkSize       = 64
      LimitedSizeLobMode = true
      LobMaxSize         = 32
    }
  })
}