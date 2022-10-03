FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    wget \
    unzip \
  && rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://releases.hashicorp.com/terraform/1.3.1/terraform_1.3.1_linux_amd64.zip \
  && unzip terraform_1.3.1_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_1.3.1_linux_amd64.zip

WORKDIR /usr/app/src

COPY cloudwatch.tf ./
COPY main.tf ./
COPY variable.tf ./
COPY userdata.sh ./
COPY scripts.sh ./

RUN terraform init
RUN ./scripts.sh