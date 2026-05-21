locals {
  backend_env = join("\n", [
    "PORT=8080",
    "MONGO_URI=${var.mongodb_uri}",
    "DB_NAME=${var.db_name}",
    "JWT_SECRET_KEY=${var.jwt_secret}",
    "ENABLE_CACHE=${var.enable_cache}",
    "REDIS_ADDR=${var.redis_endpoint}:${var.redis_port}",
    "LOG_LEVEL=INFO",
    "LOG_FORMAT=json",
    "ALLOWED_ORIGINS=*",
  ])
}
