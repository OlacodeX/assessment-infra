data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "frontend" {

  bucket = "${var.project_name}-frontend-${data.aws_caller_identity.current.account_id}"
}
resource "aws_s3_bucket_website_configuration" "frontend" {

  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }
}