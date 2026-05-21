resource "aws_elasticache_subnet_group" "redis" {

  name = "${var.project_name}-redis-subnet"

  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "redis" {

  name = "${var.project_name}-redis-sg"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_cluster" "redis" {

  cluster_id = "assessment-redis"

  engine = "redis"

  node_type = "cache.t3.micro"

  num_cache_nodes = 1

  port = 6379

  subnet_group_name = aws_elasticache_subnet_group.redis.name

  security_group_ids = [aws_security_group.redis.id]
}
