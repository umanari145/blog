

resource "aws_s3_bucket" "web_app" {
  bucket = "skill-up-engineering"
}

resource "aws_s3_bucket_website_configuration" "web_app" {
  bucket = aws_s3_bucket.web_app.bucket
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "app-ownership-controls" {
  bucket = aws_s3_bucket.web_app.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "acl" {
  depends_on = [aws_s3_bucket_ownership_controls.app-ownership-controls]
  bucket     = aws_s3_bucket.web_app.id
  acl        = "public-read"
}

resource "aws_s3_bucket_public_access_block" "access_block" {
  bucket                  = aws_s3_bucket.web_app.id
  block_public_acls       = false
  # この設定だと一部不完全で画面からの修正が必要
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.web_app.id

  depends_on = [
    aws_s3_bucket_public_access_block.access_block
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.web_app.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket_website_configuration.web_app.bucket
  key          = "index.html"
  content_type = "text/html"
}

