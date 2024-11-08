#!/bin/bash

source aws_configure.txt
# Docker login
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build image
# ローカルのbuildは他のところでやっているため不要
#docker build -t $CONTAINER_NAME .

# Tag
docker tag $CONTAINER_NAME:latest $REPO_URL:latest

# Push image
docker push $REPO_URL:latest
