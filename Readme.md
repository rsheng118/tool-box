## general docker container tool box

this is a container that include toolings for connecting to cloud environments.
for debugging and testing.

## used for quick run linux enviornment

## pull image
docker pull harbor.rsheng.org/public/tool-box:latest

## run image
docker run -it --name toolbox harbor.rsheng.org/public/tool-box:latest /bin/bash

## build image

docker build --tag tool-box:latest .
docker buildx build --platform linux/arm64,linux/amd64 --tag tool-box:latest .

## push push image
