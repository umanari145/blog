

resource "aws_s3_bucket" "web_app" {
  bucket = var.domain_name
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
  bucket = aws_s3_bucket.web_app.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
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
        Principal = {"Service": "cloudfront.amazonaws.com"},
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


# Cloudfrontのアクセスログ格納用バケット
resource "aws_s3_bucket" "cloudfront_log" {
  bucket = "cfn-log-${var.domain_name}"
}

resource "aws_s3_bucket_ownership_controls" "cloudfront_log" {
  bucket = aws_s3_bucket.cloudfront_log.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cloudfront_log" {
  depends_on = [aws_s3_bucket_ownership_controls.cloudfront_log]
  bucket = aws_s3_bucket.cloudfront_log.id
  acl    = "private"
}

# ログのライフサイクルルール
resource "aws_s3_bucket_lifecycle_configuration" "cloudfront_log" {
  bucket = aws_s3_bucket.cloudfront_log.id
  rule {
    id = "rule-1"
    status = "Enabled"
    expiration {
      # 180日
      days = "180"
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_log" {
  bucket = aws_s3_bucket.cloudfront_log.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {"Service": "cloudfront.amazonaws.com"},
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.cloudfront_log.arn}/*"
      }
    ]
  })
}