data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "backend" {

  name_prefix   = "backend-template"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  update_default_version = true

  vpc_security_group_ids = [
    aws_security_group.backend_sg.id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.profile.name
  }

  user_data = base64encode(
    templatefile("${path.module}/user-data.sh.tpl", {
      backend_env_b64    = base64encode(local.backend_env)
      ecr_repository_url = aws_ecr_repository.backend.repository_url
      aws_region         = var.aws_region
    })
  )
}