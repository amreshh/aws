FROM registry.opensuse.org/opensuse/leap:15

ENV OPENTOFU_VERSION="1.6.1-1"

ADD ./opentofu.repo /etc/zypp/repos.d/opentofu.repo

RUN zypper --gpg-auto-import-keys refresh opentofu
RUN zypper --gpg-auto-import-keys refresh opentofu-source
RUN zypper install -y tar gzip unzip git openssh tofu-${OPENTOFU_VERSION}

# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
RUN unzip -d /tmp/ /tmp/awscliv2.zip
RUN ./tmp/aws/install
RUN echo "complete -C '/usr/local/bin/aws_completer' aws" >> ~/.bashrc