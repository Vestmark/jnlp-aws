FROM jenkins/inbound-agent

USER root

RUN apt-get update && apt-get install -y sudo curl zip unzip less groff python3 python3-pip python-is-python3 build-essential zlib1g-dev libssl-dev libncurses-dev libffi-dev libsqlite3-dev libreadline-dev libbz2-dev amazon-ecr-credential-helper jq

# Install AWS CLI
ENV AWSCLI_ZIP "awscliv2.zip"

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o ${AWSCLI_ZIP} \
  && unzip ${AWSCLI_ZIP} \
  && ./aws/install \
  && rm ${AWSCLI_ZIP}
  
# Install TF Switch 
RUN curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash

# Install TG Switch
RUN curl -L https://raw.githubusercontent.com/warrensbox/tgswitch/release/install.sh | bash
  
# Terraform Quality Analysis Tools
RUN curl https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
RUN pip install checkov

# Infracost
RUN curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

USER jenkins

# Set base TF & TG Versions
RUN mkdir /home/jenkins/bin
RUN tfswitch -b /home/jenkins/bin/terraform --latest-stable 1.0
RUN tgswitch -b /home/jenkins/bin/terragrunt 0.31.7

RUN cd /home/jenkins/bin && \
  curl -LJ https://github.com/aquasecurity/tfsec/releases/download/v0.56.0/tfsec-linux-amd64 -o tfsec && \
  chmod 755 tfsec

RUN curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E "https://.+?_Linux_x86_64.tar.gz")" > terrascan.tar.gz && \
  tar -xf terrascan.tar.gz terrascan && rm terrascan.tar.gz && \
  install terrascan /home/jenkins/bin && rm terrascan && \
  chmod 755 /home/jenkins/bin/terrascan
    
ENV PATH="/home/jenkins/bin:${PATH}"

# Install EB CLI
RUN pip install --user virtualenv
ENV PATH="/home/jenkins/.local/bin:${PATH}"
RUN git clone https://github.com/aws/aws-elastic-beanstalk-cli-setup.git \
  && python ./aws-elastic-beanstalk-cli-setup/scripts/ebcli_installer.py \
  && rm -r aws-elastic-beanstalk-cli-setup
ENV PATH="/home/jenkins/.ebcli-virtual-env/executables:${PATH}"
