FROM jenkins/inbound-agent

USER root

RUN apt-get update && apt-get install -y curl zip unzip less groff python3-pip build-essential zlib1g-dev libssl-dev libncurses-dev libffi-dev libsqlite3-dev libreadline-dev libbz2-dev amazon-ecr-credential-helper

# Install AWS CLI
ENV AWSCLI_ZIP "awscliv2.zip"

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o ${AWSCLI_ZIP} \
  && unzip ${AWSCLI_ZIP} \
  && ./aws/install \
  && rm ${AWSCLI_ZIP}

# Install TF Switch 
RUN curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash
RUN tfswitch 0.13.7

# Install TG Switch
RUN curl -L https://raw.githubusercontent.com/warrensbox/tgswitch/release/install.sh | bash
RUN tgswitch 0.25.5

# Terraform Quality Analysis Tools
RUN curl https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
RUN pip3 install checkov

USER jenkins

RUN mkdir /home/jenkins/bin && \
  cd /home/jenkins/bin && \
  curl -LJ https://github.com/aquasecurity/tfsec/releases/download/v0.56.0/tfsec-linux-amd64 -o tfsec && \
  chmod 755 tfsec

RUN curl -L "$(curl -s https://api.github.com/repos/accurics/terrascan/releases/latest | grep -o -E "https://.+?_Linux_arm64.tar.gz")" > terrascan.tar.gz && \
  tar -xf terrascan.tar.gz terrascan && rm terrascan.tar.gz && \
  install terrascan /home/jenkins/bin && rm terrascan && \
  chmod 755 /home/jenkins/bin/terrascan
  
ENV PATH="/home/jenkins/bin:${PATH}"

# Install EB CLI
RUN git clone https://github.com/aws/aws-elastic-beanstalk-cli-setup.git \
  && ./aws-elastic-beanstalk-cli-setup/scripts/bundled_installer \
  && rm -r aws-elastic-beanstalk-cli-setup

ENV PATH="/home/jenkins/.ebcli-virtual-env/executables:${PATH}"
