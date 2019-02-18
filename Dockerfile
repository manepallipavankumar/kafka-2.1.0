RUN source $HOME/.profile

ENV CONFLUENT_VERSION=5.0 \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64


# install pre-requisites and Confluent
RUN set -x \
    && apt-get update \
    && apt-get install -y openjdk-8-jre-headless wget netcat-openbsd software-properties-common \
    && wget -qO - http://packages.confluent.io/deb/$CONFLUENT_VERSION/archive.key | apt-key add - \
    && add-apt-repository "deb [arch=amd64] http://packages.confluent.io/deb/$CONFLUENT_VERSION stable main" \
    && apt-get update \
    && apt-get install -y confluent-platform-oss-2.11

# install pre-requisites and SDK
CMD echo "*************** Installing kubectl ******************"
ADD https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl
CMD echo "*************** kubectl Installation Completed ******************"

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils \
    && echo '**Installing zip,unzip,curl **' \
    && apt-get install -y zip \
    && apt-get install -y unzip \
    && apt-get install -y curl \
    && apt-get install -y wget \
    && echo '*************** Creating directory for GO ******************' \
    && mkdir -p /opt/go/bin \
    && echo '*************** Installing Go ******************' \
    && curl https://storage.googleapis.com/golang/go1.11.5.linux-amd64.tar.gz | tar xvzf - -C /usr/local --strip-components=1 \
    && echo '**Installing Git **' \
    && apt-get install -y git \
    && cd $GOBIN \
    && echo '*************** Fetching framework ******************' \
    && wget https://github.com/operator-framework/operator-sdk/releases/download/v0.2.1/operator-sdk-v0.2.1-x86_64-linux-gnu -O /opt/go/bin/operator-sdk \
    && chmod +x /opt/go/bin/operator-sdk \
    && echo '*************** Installing Dep ******************' \
    && curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

# Define default command.
CMD trap : TERM INT; sleep infinity & wait