resource "aws_ecr_repository" "backend" {

  name = "assessment-backend"

  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}