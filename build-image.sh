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

echo "Successfully built and pushed image, hooray!"