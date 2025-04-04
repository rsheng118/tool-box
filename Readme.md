## general docker container tool box

this is a container that include toolings for connecting to cloud environments.
for debugging and testing.

## used for quick run linux enviornment

## build image

docker build --tag tool-box:latest .

docker buildx build --platform linux/arm64,linux/amd64 --tag tool-box:latest .
