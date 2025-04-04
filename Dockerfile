FROM ubuntu:24.04
# vars
ARG LOCAL_USER=su
ARG KUBECTL_VER=v1.31
ARG RANCHER_CLI_VER=v2.9.0
ARG PYTHON_VERSION=3.12
ARG POWERSHELL_VERSION=7.5.0

# install package
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

RUN apt install -y python${PYTHON_VERSION}

## install kubectl
RUN curl -fsSL "https://pkgs.k8s.io/core:/stable:/$KUBECTL_VER/deb/Release.key" | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
RUN sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring
RUN echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBECTL_VER/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
RUN sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

RUN apt update && apt install -y kubectl

## install gcloud util
RUN if [ "$(uname -m)" = "aarch64" ] || [ "$(uname -m)" = "arm64" ]; then \
    curl "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-arm.tar.gz" -o google_cli.zip; \
    else \
    curl "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz" -o google_cli.zip; \
    fi

RUN tar -xf google_cli.zip
RUN mv google-cloud-sdk /usr/local/google-cloud-sdk
RUN /usr/local/google-cloud-sdk/install.sh --quiet
RUN rm -rf google_cli.zip

# RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
# RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# RUN apt update && apt install -y google-cloud-cli \
#                                     google-cloud-cli-gke-gcloud-auth-plugin
# RUN mkdir -p /opt/homebrew/share/google-cloud-sdk/bin && \
#     cp /usr/bin/gke-gcloud-auth-plugin /opt/homebrew/share/google-cloud-sdk/bin/gke-gcloud-auth-plugin

## install aws cli
RUN if [ "$(uname -m)" = "aarch64" ] || [ "$(uname -m)" = "arm64" ]; then \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o awscliv2.zip; \
    else \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip; \
    fi
RUN unzip awscliv2.zip && ./aws/install
RUN rm -rf aws && rm awscliv2.zip

## install azure cli
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# install powershell
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
    fi
RUN tar -xf rancher.tar.gz
RUN cp rancher-$RANCHER_CLI_VER/rancher /usr/bin/rancher
RUN rm -rf rancher*

## install argocd cli
RUN ARGOCD_VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/') && \
    if [ "$(uname -m)" = "aarch64" ] || [ "$(uname -m)" = "arm64" ]; then \
    curl -L -o /tmp/argocd https://github.com/argoproj/argo-cd/releases/download/$ARGOCD_VERSION/argocd-linux-arm64; \
    else \
    curl -L -o /tmp/argocd https://github.com/argoproj/argo-cd/releases/download/$ARGOCD_VERSION/argocd-linux-amd64; \
    fi
RUN chmod +x /tmp/argocd && mv /tmp/argocd /usr/local/bin/argocd 

# setup user env
RUN useradd -ms /bin/zsh $LOCAL_USER
RUN usermod -aG sudo $LOCAL_USER
RUN echo "$LOCAL_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/nopass
USER $LOCAL_USER
WORKDIR /home/$LOCAL_USER
## install omz
RUN curl -fsSL "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" > install.sh
RUN chmod u+x install.sh && y | ./install.sh
RUN rm install.sh
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
## install powerlevel10k
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
## config okta-awscli
RUN pip3 install okta-awscli --break-system-packages
RUN cp -rf $(python3 -m site --user-site)/oktaawscli /home/$LOCAL_USER/.oktaawscli
## install helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# copy files
COPY --chown=$LOCAL_USER:$LOCAL_USER --chmod=644 p10k.zsh .p10k.zsh
COPY --chown=$LOCAL_USER:$LOCAL_USER --chmod=644 zshrc .zshrc

# USER root
ENTRYPOINT [ "/bin/zsh" ]
