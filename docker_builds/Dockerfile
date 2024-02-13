FROM docker.io/fedora:40

ADD ./script.sh /tmp/script.sh

RUN chmod +x /tmp/script.sh
RUN dnf install -y unzip

# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
RUN unzip -d /tmp/ /tmp/awscliv2.zip
RUN ./tmp/aws/install

CMD "/tmp/script.sh"