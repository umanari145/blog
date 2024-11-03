
resource "null_resource" "blog_python_lambda" {
  triggers = {
    // MD5 チェックし、トリガーにする
    file_content_md5 = md5(file("${path.module}/dockerbuild.sh"))
  }

  provisioner "local-exec" {
    // ローカルのスクリプトを呼び出す
    command = "sh ${path.module}/dockerbuild.sh"

    // スクリプト専用の環境変数
    environment = {
      AWS_REGION     = var.region
      AWS_ACCOUNT_ID = var.aws_account_id
      REPO_URL       = aws_ecr_repository.image_repository.repository_url
      CONTAINER_NAME = "blog_python_lambda"
    }
  }
}

resource "aws_ecr_repository" "image_repository" {
  name                 = "blog-lambda"
  force_delete         = true
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "lambda-policy" {
  repository = aws_ecr_repository.image_repository.name
  policy = file("${path.module}/aws_ecr_lifecycle_policy.json")
}