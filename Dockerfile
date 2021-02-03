FROM jenkins/inbound-agent

USER root

RUN apt-get update && apt-get install -y zip unzip less groff python3-pip build-essential zlib1g-dev libssl-dev libncurses-dev libffi-dev libsqlite3-dev libreadline-dev libbz2-dev amazon-ecr-credential-helper

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

# Terraform Quality Analysis Tools
RUN curl https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
RUN pip3 install checkov
RUN mkdir /home/jenkins/bin && \
  cd /home/jenkins/bin && \
  curl -LJO https://github.com/tfsec/tfsec/releases/download/v0.37.1/tfsec-linux-amd64 -o tfsec
ENV PATH="/home/jenkins/bin:${PATH}"

USER jenkins

# Install EB CLI
RUN git clone https://github.com/aws/aws-elastic-beanstalk-cli-setup.git \
  && ./aws-elastic-beanstalk-cli-setup/scripts/bundled_installer \
  && rm -r aws-elastic-beanstalk-cli-setup

ENV PATH="/home/jenkins/.ebcli-virtual-env/executables:${PATH}"
