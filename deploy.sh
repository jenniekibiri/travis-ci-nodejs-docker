#!/bin/sh

# Stop script on first error
set -e

IMAGE_NAME="jennykibiri/freestyle-jenkins-node-app"
IMAGE_TAG=$(git rev-parse --short HEAD) # first 7 characters of the current commit hash


# Decode SSH key
echo "${SSH_KEY}"
# echo 'export SSH_KEY="$(echo ${SSH_KEY} | base64 -d)"' 

echo "export SSH_KEY=\"${SSH_KEY}\""

echo "${SSH_KEY}"  > ~/.ssh/id_rsa


chmod 600  ~/.ssh/id_rsa 
  # private keys need to have strict permission to be accepted by SSH agent

# Add production server to known hosts
echo "${SSH_HOST}"  >> ~/.ssh/known_hosts

echo "Deploying via remote SSH"
# ssh into the server and run the following commands
ssh -o StrictHostKeyChecking=no  "root@${SSH_HOST}" \
  "echo "${PASSWORD}" | docker login -u "${USERNAME}" --password-stdin \
  && docker pull ${IMAGE_NAME}:${IMAGE_TAG} \
  && docker stop freelestyle-jenkins-node-app \
  && docker rm freelestyle-jenkins-node-app \
  && docker run --init -d --name freelestyle-jenkins-node-app -p 3000:3000 ${IMAGE_NAME}:${IMAGE_TAG} \
  && docker system prune -af" # remove unused images to free up space

echo "Successfully deployed, hooray!"