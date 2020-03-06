FROM centos:centos7

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

RUN yum install -y sudo  \
    python2-pip \
    wget \
    nmap-ncat \
    jq \
    java-1.8.0-openjdk \
    java-1.8.0-openjdk-devel \
    autoconf \
    automake \
    libtool \
    cmake \
    zlib1g-dev \
    pkg-config \
    libssl-dev \
    openssl \
    openssl-devel \
    zlib-devel \
    gcc-c++

# CMAKE
RUN wget https://cmake.org/files/v3.10/cmake-3.10.0-Linux-x86_64.tar.gz \
    && tar zxf cmake-3.10.0-Linux-x86_64.tar.gz \
    && rm -rf cmake-3.10.0-Linux-x86_64.tar.gz
ENV PATH="/cmake-3.10.0-Linux-x86_64/bin:${PATH}"

# MAVEN
RUN wget http://mirror.ox.ac.uk/sites/rsync.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz \
    && tar zxf apache-maven-3.6.3-bin.tar.gz \
    && rm -rf apache-maven-3.6.3-bin.tar.gz
ENV PATH="/apache-maven-3.6.3/bin:${PATH}"

RUN mkdir -p /opt/protobuf-src \
    && curl -L -s -S \
      https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protobuf-java-3.7.1.tar.gz \
      -o /opt/protobuf.tar.gz \
    && tar xzf /opt/protobuf.tar.gz --strip-components 1 -C /opt/protobuf-src \
    && cd /opt/protobuf-src \
    && ./configure --prefix=/opt/protobuf \
    && make install \
    && cd /root \
    && rm -rf /opt/protobuf-src
ENV PROTOBUF_HOME /opt/protobuf
ENV PATH "${PATH}:/opt/protobuf/bin"
ENV LD_LIBRARY_PATH="/opt/protobuf/lib:${LD_LIBRARY_PATH}"

ENV PATH="/usr/lib/jvm/java-1.8.0-openjdk/bin:${PATH}"
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk