FROM ubuntu:22.04

COPY requirements.txt /tmp/requirements.txt

# Pre-Requisites
RUN apt-get update && \
    apt-get -y install bash \
    pass vim curl unzip zip make git python3 python3-pip && \
    apt-get clean all

# Python
COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && \
    ls && \
    unzip awscliv2 && \
    ./aws/install #-i /usr/local/bin

# Terraform
ENV TF_VERSION="1.1.3"
RUN curl -s "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" -o "terraform.zip" && \
    unzip terraform.zip && \
    rm -f terraform.zip && \
    chmod +x terraform && \
    mv terraform /usr/bin
