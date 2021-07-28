FROM jenkins/inbound-agent

USER root

RUN apt-get update && apt-get install -y unzip build-essential zlib1g-dev libssl-dev libncurses-dev libffi-dev libsqlite3-dev libreadline-dev libbz2-dev amazon-ecr-credential-helper

# Install AWS CLI
ENV AWSCLI_ZIP "awscliv2.zip"

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o ${AWSCLI_ZIP} \
  && unzip ${AWSCLI_ZIP} \
  && ./aws/install \
  && rm ${AWSCLI_ZIP}

# Install Terraform
ENV TERRAFORM_VERSION 0.13.7
ENV TERRAFORM_URL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
ENV TERRAFORM_CHECKSUM "4a52886e019b4fdad2439da5ff43388bbcc6cce9784fde32c53dcd0e28ca9957"

RUN curl -SL "${TERRAFORM_URL}" --output terraform.zip \
  && echo "${TERRAFORM_CHECKSUM} terraform.zip" | sha256sum -c - \
  && unzip "terraform.zip" -d /usr/local/bin \
  && rm terraform.zip

# Install Terragrunt
ENV TERRAGRUNT_VERSION 0.25.5
ENV TERRAGRUNT_URL "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64"
ENV TERRAGRUNT_CHECKSUM "a7699227a5d8b02f9facaeea9919261e727ac2dec2f81fee6455a52d06df4648"

RUN curl -sL "${TERRAGRUNT_URL}" -o /bin/terragrunt \
  && echo "${TERRAGRUNT_CHECKSUM} /bin/terragrunt" | sha256sum -c - \
  && chmod +x /bin/terragrunt

USER jenkins

# Install EB CLI
RUN git clone https://github.com/aws/aws-elastic-beanstalk-cli-setup.git \
  && ./aws-elastic-beanstalk-cli-setup/scripts/bundled_installer \
  && rm -r aws-elastic-beanstalk-cli-setup

ENV PATH="/home/jenkins/.ebcli-virtual-env/executables:${PATH}"
