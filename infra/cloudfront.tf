resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name = aws_s3_bucket.web_app.bucket_regional_domain_name
    origin_id = aws_s3_bucket.web_app.id
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
  }

  enabled =  true
  default_root_object = "index.html"

  #アクセスログ
  logging_config {
    bucket = aws_s3_bucket.cloudfront_log.bucket_domain_name
    prefix = "cloudfront/"
  }

  default_cache_behavior {
    allowed_methods = [ "GET", "HEAD" ]
    cached_methods = [ "GET", "HEAD" ]
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id = aws_s3_bucket.web_app.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  #S3にアクセスしているのでroutingでトップ以外は403になってしまうが
  #SPAなので全てindexに飛ばす
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html" # トップページにリダイレクト
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_access_control" "main" {
  name = "cf-s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}
