FROM ubuntu:18.04

# Set environment variables.
ENV GOROOT=/usr/local/go \
    GOPATH=/opt/go \
    GOBIN=/opt/go/bin \
    KUBECTL_VERSION=v1.11.7 \
    CONFLUENT_VERSION=5.0 \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    KAFKA_BIN_DIR=/opt/kafka/bin \
    KAFKA_CONFIG_DIR=/etc/bmw/kafka \
    KAFKA_DATA_DIR=/var/lib/kafka \
    KAFKA_LOG_DIR=/var/log/kafka \
    ZK_BIN_DIR=/opt/zookeeper/bin \
    ZK_CONFIG_DIR=/etc/zookeeper \
    ZK_DATA_DIR=/var/lib/zookeeper/data \
    ZK_DATA_LOG_DIR=/var/lib/zookeeper/log \
    ZK_LOG_DIR=/var/log/zookeeper

#To Export the PATH Variable
ENV PATH "${GOROOT}:${GOPATH}:${GOBIN}:${PATH}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/usr/local/go/bin"

COPY scripts/* ${ZK_BIN_DIR}/
COPY bin/* ${KAFKA_BIN_DIR}/
COPY config/* ${KAFKA_CONFIG_DIR}/
RUN set -x \
    && mkdir -p ${KAFKA_DATA_DIR} \
    && chown -R :root ${KAFKA_CONFIG_DIR} ${KAFKA_DATA_DIR} \
    && chmod -R g+rwx ${KAFKA_CONFIG_DIR} ${KAFKA_DATA_DIR} \
    && chmod +x ${KAFKA_BIN_DIR}/*.sh
    
#installing zip,unzip,curl
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils \
    && echo '**Installing zip,unzip,curl **' \
    && apt-get install -y zip \
    && apt-get install -y unzip \
    && apt-get install -y curl \
    && apt-get install -y wget

# install pre-requisites and Confluent
RUN set -x \
    && apt-get update \
    && apt-get install -y openjdk-8-jre-headless wget netcat-openbsd software-properties-common \
    && wget -qO - http://packages.confluent.io/deb/$CONFLUENT_VERSION/archive.key | apt-key add - \
    && add-apt-repository "deb [arch=amd64] http://packages.confluent.io/deb/$CONFLUENT_VERSION stable main" \
    && apt-get update \
    && apt-get install -y confluent-platform-oss-2.11

# install kubectl
CMD echo "*************** Installing kubectl ******************"
ADD https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl
CMD echo "*************** kubectl Installation Completed ******************"

# install GO and Dep and Git
RUN echo '*************** Creating directory for GO ******************' \
    && mkdir -p /opt/go/bin \
    && echo '*************** Installing Go ******************' \
    && curl https://storage.googleapis.com/golang/go1.11.5.linux-amd64.tar.gz | tar xvzf - -C /usr/local \
    && echo '**Installing Git **' \
    && apt-get install -y git \
    && echo '*************** Installing Dep ******************' \
    && curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh 

# install Operator Framework
RUN mkdir -p $GOPATH/src/github.com/operator-framework \
    && cd $GOPATH/src/github.com/operator-framework \
    && echo '*************** Fetching framework ******************' \
    && git clone https://github.com/operator-framework/operator-sdk \
    && cd operator-sdk \
    && git checkout master \
    && apt-get install -y make \
    && make dep \
    && make install

# Define default command.
CMD trap : TERM INT; sleep infinity & wait
