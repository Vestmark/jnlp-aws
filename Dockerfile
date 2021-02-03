FROM jenkins/inbound-agent

USER root

RUN apt-get update && apt-get install -y unzip build-essential zlib1g-dev libssl-dev libncurses-dev libffi-dev libsqlite3-dev libreadline-dev libbz2-dev amazon-ecr-credential-helper

# Install AWS CLI
ENV AWSCLI_ZIP "awscliv2.zip"

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o ${AWSCLI_ZIP} \
  && unzip ${AWSCLI_ZIP} \
  && ./aws/install \
  && rm ${AWSCLI_ZIP}

# Install TF Switch 
RUN curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash
RUN tfswitch 0.13.6
RUN tfswitch 0.12.30

# Install TG Switch
RUN curl -L https://raw.githubusercontent.com/warrensbox/tgswitch/release/install.sh | bash
RUN tgswitch 0.23.40

# Install

USER jenkins

# Install EB CLI
RUN git clone https://github.com/aws/aws-elastic-beanstalk-cli-setup.git \
  && ./aws-elastic-beanstalk-cli-setup/scripts/bundled_installer \
  && rm -r aws-elastic-beanstalk-cli-setup

ENV PATH="/home/jenkins/.ebcli-virtual-env/executables:${PATH}"
