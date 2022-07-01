#!/bin/sh

# Stop script on first error
set -e

IMAGE_NAME="jennykibiri/freestyle-jenkins-node-app"
IMAGE_TAG=$(git rev-parse --short HEAD) # first 7 characters of the current commit hash

echo "Building Docker image ${IMAGE_NAME}:${IMAGE_TAG}, and tagging as latest"
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .
docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${IMAGE_NAME}:latest"

echo "Authenticating and pushing image to Docker Hub"
echo "${PASSWORD}" | docker login -u "${USERNAME}" --password-stdin
docker push "${IMAGE_NAME}:${IMAGE_TAG}"
docker push "${IMAGE_NAME}:latest"



echo "Deploying via remote SSH"
ssh  "root@${$SSH_HOST}" \
  "echo "${PASSWORD}" | docker login -u "${USERNAME}" --password-stdin \
  && docker pull ${IMAGE_NAME}:${IMAGE_TAG} \
  && docker stop autodeploy-docker \
  && docker rm autodeploy-docker \
  && docker run --init -d --name autodeploy-docker -p 3000:3000 ${IMAGE_NAME}:${IMAGE_TAG} \
  && docker system prune -af" # remove unused images to free up space

echo "Successfully deployed, hooray!"