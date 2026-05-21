module "networking" {
  source = "./modules/networking"
}

module "storage" {

  source = "./modules/storage"

  project_name = var.project_name

  vpc_id = module.networking.vpc_id

  vpc_cidr = module.networking.vpc_cidr

  private_subnet_ids = module.networking.private_subnet_ids
}

module "compute" {

  source = "./modules/compute"

  vpc_id = module.networking.vpc_id

  public_subnet_ids = module.networking.public_subnet_ids

  private_subnet_ids = module.networking.private_subnet_ids

  instance_type = var.instance_type

  mongodb_uri = var.mongodb_uri

  jwt_secret = var.jwt_secret

  redis_port = var.redis_port

  redis_endpoint = module.storage.redis_endpoint

  aws_region = var.aws_region

  db_name = var.db_name

  enable_cache = var.enable_cache
}

module "monitoring" {
  source = "./modules/monitoring"
}