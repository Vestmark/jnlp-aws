FROM jenkins/jnlp-slave

USER root

RUN apt-get update && apt-get install -y unzip build-essential zlib1g-dev libssl-dev libncurses-dev libffi-dev libsqlite3-dev libreadline-dev libbz2-dev

# Install AWS CLI
ENV AWSCLI_ZIP "awscliv2.zip"

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o ${AWSCLI_ZIP} \
	&& unzip ${AWSCLI_ZIP} \
	&& ./aws/install \
	&& rm ${AWSCLI_ZIP}

# Install Terraform
ENV TERRAFORM_VERSION 0.12.24
ENV TERRAFORM_URL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
ENV TERRAFORM_CHECKSUM "602d2529aafdaa0f605c06adb7c72cfb585d8aa19b3f4d8d189b42589e27bf11"

RUN curl -SL "${TERRAFORM_URL}" --output terraform.zip \
	&& echo "${TERRAFORM_CHECKSUM} terraform.zip" | sha256sum -c - \
	&& unzip "terraform.zip" -d /usr/local/bin \
	&& rm terraform.zip

# Install Terragrunt
ENV TERRAGRUNT_VERSION 0.23.12
ENV TERRAGRUNT_URL "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64"
ENV TERRAGRUNT_CHECKSUM "1d6b0d01627a5465170e746b3d8a54c13295189df1ef8bb4cee5e5264c9fa6e3"

RUN curl -sL "${TERRAGRUNT_URL}" -o /bin/terragrunt \
	&& echo "${TERRAGRUNT_CHECKSUM} /bin/terragrunt" | sha256sum -c - \
	&& chmod +x /bin/terragrunt

USER jenkins

# Install EB CLI
RUN git clone https://github.com/aws/aws-elastic-beanstalk-cli-setup.git \
	&& ./aws-elastic-beanstalk-cli-setup/scripts/bundled_installer \
	&& rm -r aws-elastic-beanstalk-cli-setup

RUN echo '#!/bin/bash\n\
cat << \EOF >> ~/.bash_profile\n\
export PATH="/home/jenkins/.ebcli-virtual-env/executables:$PATH"\n\
EOF\n'\
> ~/updatePath.sh
RUN chmod a+x updatePath.sh
RUN ./updatePath.sh
RUN rm ./updatePath.sh