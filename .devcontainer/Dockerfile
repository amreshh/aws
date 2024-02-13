FROM docker.io/fedora:40

ENV TERRAFORM_VERSION="1.7.2"

RUN dnf install -y unzip git

# Terraform
RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o /tmp/terraform.zip
RUN unzip /tmp/terraform.zip -d /usr/local/bin/

# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
RUN unzip -d /tmp/ /tmp/awscliv2.zip
RUN ./tmp/aws/install
RUN echo "complete -C '/usr/local/bin/aws_completer' aws" >> ~/.bashrc