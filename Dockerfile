FROM ubuntu:24.04

## vars
ARG LOCAL_USER=su
ARG KUBECTL_VER=v1.31
ARG RANCHER_CLI_VER=v2.9.0
ARG PYTHON_VERSION=3.12
ARG POWERSHELL_VERSION=7.5.0


## install package
RUN apt update && apt upgrade -y
RUN apt update --fix-missing
RUN apt install -y sudo \
                    net-tools \
                    curl \
                    iputils-ping \
                    gnupg \
                    ssh \
                    nmap \
                    netcat-openbsd \
                    nano \
                    vim \
                    jq \
                    yq \
                    zip \
                    unzip \
                    htop \
                    neofetch \
                    git \
                    zsh \
                    pip \
                    host \
                    powerline \
                    kubectx \
                    fonts-font-awesome \
                    apt-transport-https \
                    ca-certificates 

## install python
RUN apt install -y python${PYTHON_VERSION}

## install kubectl
RUN curl -fsSL "https://pkgs.k8s.io/core:/stable:/$KUBECTL_VER/deb/Release.key" | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg; \
    chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring; \
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBECTL_VER/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list; \
    chmod 644 /etc/apt/sources.list.d/kubernetes.list; \
    apt update && apt install -y kubectl

## install gcloud util
RUN if [ "$(uname -m)" = "aarch64" ] || [ "$(uname -m)" = "arm64" ]; then \
    curl "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-arm.tar.gz" -o google_cli.zip; \
    else \
    curl "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz" -o google_cli.zip; \
    fi; \
    tar -xvf google_cli.zip && mv google-cloud-sdk /usr/local/google-cloud-sdk; \
    /usr/local/google-cloud-sdk/install.sh --quiet; \
    rm -rf google_cli.zip


## install aws cli
RUN if [ "$(uname -m)" = "aarch64" ] || [ "$(uname -m)" = "arm64" ]; then \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o awscliv2.zip; \
    else \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip; \
    fi; \
    unzip awscliv2.zip && ./aws/install; \
    rm -rf aws && rm awscliv2.zip

## install azure cli
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

## install powershell
RUN if [ "$(uname -m)" = "aarch64" ] || [ "$(uname -m)" = "arm64" ]; then \
        curl -L -o /tmp/powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v7.5.0/powershell-7.5.0-linux-arm64.tar.gz; \
        mkdir -p /opt/microsoft/powershell/7; \
        tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7; \
        chmod +x /opt/microsoft/powershell/7/pwsh; \
        ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh; \
    else \
        wget "https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell_${POWERSHELL_VERSION}-1.deb_amd64.deb"; \
        dpkg -i powershell_${POWERSHELL_VERSION}-1.deb_amd64.deb; \
        apt install -f; \
        rm powershell_${POWERSHELL_VERSION}-1.deb_amd64.deb; \
    fi

## install rancher cli
RUN if [ "$(uname -m)" = "aarch64" ] || [ "$(uname -m)" = "arm64" ]; then \
    curl -L "https://github.com/rancher/cli/releases/download/${RANCHER_CLI_VER}/rancher-linux-arm-${RANCHER_CLI_VER}.tar.gz" -o rancher.tar.gz; \
    else \
    curl -L "https://github.com/rancher/cli/releases/download/${RANCHER_CLI_VER}/rancher-linux-amd64-${RANCHER_CLI_VER}.tar.gz" -o rancher.tar.gz; \
    fi; \
    tar -xvf rancher.tar.gz; \
    cp rancher-$RANCHER_CLI_VER/rancher /usr/bin/rancher; \
    rm -rf rancher*

## install argocd cli
RUN ARGOCD_VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/') && \
    if [ "$(uname -m)" = "aarch64" ] || [ "$(uname -m)" = "arm64" ]; then \
    curl -L -o /tmp/argocd https://github.com/argoproj/argo-cd/releases/download/$ARGOCD_VERSION/argocd-linux-arm64; \
    else \
    curl -L -o /tmp/argocd https://github.com/argoproj/argo-cd/releases/download/$ARGOCD_VERSION/argocd-linux-amd64; \
    fi; \
    chmod +x /tmp/argocd && mv /tmp/argocd /usr/local/bin/argocd 

## install kubectl
RUN if [ "$(uname -m)" = "aarch64" ] || [ "$(uname -m)" = "arm64" ]; then \
        curl -L -o kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl" ;\
    else \
        curl -L -o kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"; \
    fi; \
    chmod 777 kubectl; \
    mv kubectl /usr/bin

## install cilium cli
RUN CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt) && \
    if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; \
    else CLI_ARCH=amd64; fi && \
    curl -L -o /tmp/cilium.tar.gz --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz; \
    tar -xzvf /tmp/cilium.tar.gz; \
    chmod 777 cilium; \
    mv cilium /usr/bin; \
    rm /tmp/cilium.tar.gz

## install terraform tenv
RUN LATEST_VERSION=$(curl -s https://api.github.com/repos/tofuutils/tenv/releases/latest | jq -r .tag_name) && \
    if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; \
    else CLI_ARCH=amd64; fi && \
    curl -L -o /tmp/tenv.deb "https://github.com/tofuutils/tenv/releases/latest/download/tenv_${LATEST_VERSION}_${CLI_ARCH}.deb"; \
    dpkg -i /tmp/tenv.deb; \
    rm /tmp/tenv.deb

## setup user env
RUN useradd -ms /bin/zsh $LOCAL_USER
RUN usermod -aG sudo $LOCAL_USER
RUN echo "$LOCAL_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/nopass
## switch user
USER $LOCAL_USER
WORKDIR /home/$LOCAL_USER

## install omz
RUN curl -fsSL "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" > install.sh; \
    chmod u+x install.sh && y | ./install.sh; \
    rm install.sh; \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

## install powerlevel10k
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

## config okta-awscli
RUN pip3 install okta-awscli --break-system-packages && \
    cp -rf $(python3 -m site --user-site)/oktaawscli /home/$LOCAL_USER/.oktaawscli

## install helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

## install helm plugin
RUN helm plugin install https://github.com/helm-unittest/helm-unittest.git

## install kubectl plugin
RUN kubectl krew install oidc-login

## copy files
COPY --chown=$LOCAL_USER:$LOCAL_USER --chmod=644 p10k.zsh .p10k.zsh
COPY --chown=$LOCAL_USER:$LOCAL_USER --chmod=644 zshrc .zshrc

## USER root
ENTRYPOINT [ "/bin/zsh" ]
