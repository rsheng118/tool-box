## general docker container tool box
## used for quick run linux enviornment

## build image

docker build --tag tool-box:latest .

docker buildx build --platform linux/arm64,linux/amd64 --tag tool-box:latest .
