#!/bin/bash

##
## terraformがうまく動かないのでecrがらみはシェルで代用
##
source aws_configure.txt

aws ecr create-repository \
  --repository-name blog-lambda \
  --image-tag-mutability MUTABLE \
  --image-scanning-configuration scanOnPush=true

aws ecr put-lifecycle-policy \
  --repository-name blog-lambda \
  --lifecycle-policy-text file://aws_ecr_lifecycle_policy.json

# Docker login
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build image
# ローカルのbuildは他のところでやっているため不要
#docker build -t $CONTAINER_NAME .

# Tag
docker tag $CONTAINER_NAME $REPO_URL

# Push image
docker push $REPO_URL
