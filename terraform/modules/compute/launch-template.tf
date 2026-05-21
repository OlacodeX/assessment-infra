resource "aws_launch_template" "backend" {

  name_prefix = "backend-template"

  image_id = "ami-0c02fb55956c7d316"

  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.backend_sg.id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.profile.name
  }

  user_data = base64encode(
    templatefile("${path.module}/user-data.sh.tpl", {

      mongodb_uri = var.mongodb_uri

      jwt_secret = var.jwt_secret

      db_name = var.db_name

      enable_cache = var.enable_cache

      redis_port = var.redis_port

      redis_endpoint = var.redis_endpoint

      ecr_repository_url = aws_ecr_repository.backend.repository_url

      aws_region = var.aws_region
    })
  )
}