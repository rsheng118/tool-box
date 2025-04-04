## build image

docker buildx build --push --platform linux/arm64,linux/amd64 --tag harbor.rsheng.org/public/tool-box:latest .

## toolbox alias container
alias tool-box="docker run -it --name toolbox harbor.rsheng.org/public/tool-box:latest /bin/bash" # start new container
alias tool-box-r="docker start -ai toolbox" # re-attach to container
alias tool-box-d="docker container rm toolbox" # delete container