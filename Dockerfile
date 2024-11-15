FROM ubuntu:latest

WORKDIR /tmp
ENV TZ=Europe
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Pre-requisites
RUN apt-get update && \
    apt-get -y install bash software-properties-common \
    pass vim curl jq unzip zip make git libedit-dev lsb-release && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get -y install python3.12 python3-pip && \
    apt-get clean all

# Python
COPY ./requirements.txt /tmp/requirements.txt
RUN pip install -r ./requirements.txt


# AWS Session Manager
RUN curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_arm64/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
    dpkg -i session-manager-plugin.deb

# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && \
    ls && \
    unzip awscliv2 && \
    ./aws/install #-i /usr/local/bin

# Terraform
ENV TF_VERSION="1.1.3"
RUN curl -s "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" -o "terraform.zip" && \
    ls terraform* && \
    unzip terraform.zip && \
    rm -f terraform.zip && \
    chmod +x terraform && \
    mv terraform /usr/bin/

    
# TF ENV
RUN git clone "https://github.com/tfutils/tfenv.git" /usr/tfenv && \
    ln -s /usr/tfenv/bin/* /usr/local/bin && \
    /usr/local/bin/tfenv install $TF_VERSION && \
    /usr/local/bin/tfenv use $TF_VERSION


ENV TF_LINT_VERSION="v0.45.4"
RUN curl -s "https://github.com/terraform-linters/tflint/releases/download/${TF_LINT_VERSION}/tflint_linux_amd64.zip" -o "tflint" && \
    ls tflint* && \
    chmod +x tflint && \
    mv tflint /usr/bin


# Terragrunt
ENV TERRAGRUNT_VERSION="v0.66.3"
RUN curl -o /usr/local/bin/terragrunt -fsSL "https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" && \
    chmod +x /usr/local/bin/terragrunt

# PyEnv
RUN curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash && \
    export PYENV_ROOT="$HOME/.pyenv" && \
    mkdir /opt/pyenv && \
    mkdir /opt/pyenv/bin/ && \
    cp /root/.pyenv/bin/pyenv /opt/pyenv/bin/pyenv && \
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH" && \
    eval "$(pyenv init -)" && \
    exec $SHELL


RUN curl -sSL https://get.docker.com/ | sh