FROM centos:7.9.2009

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y sudo openssl python2-pip wget nmap-ncat jq java-11-openjdk java-11-openjdk-devel ruby krb5-libs krb5-workstation && yum clean all

# Dumb-init
RUN set -eux ; \
    ARCH="$(arch)"; \
    case "${ARCH}" in \
        x86_64) \
            url='https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64'; \
            sha256='e874b55f3279ca41415d290c512a7ba9d08f98041b28ae7c2acb19a545f1c4df'; \
            ;; \
        aarch64) \
            url='https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_aarch64'; \
            sha256='b7d648f97154a99c539b63c55979cd29f005f88430fb383007fe3458340b795e'; \
            ;; \
        *) echo "Unsupported architecture: ${ARCH}"; exit 1 ;; \
    esac; \
    curl -L ${url} -o dumb-init ; \
    echo "${sha256} *dumb-init" | sha256sum -c - ; \
    chmod +x dumb-init ; \
    mv dumb-init /usr/bin/dumb-init

# Go Su
RUN set -eux ; \
    ARCH="$(arch)"; \
    case "${ARCH}" in \
        x86_64) \
            url='https://github.com/tianon/gosu/releases/download/1.14/gosu-amd64'; \
            sha256='bd8be776e97ec2b911190a82d9ab3fa6c013ae6d3121eea3d0bfd5c82a0eaf8c'; \
            ;; \
        aarch64) \
            url='https://github.com/tianon/gosu/releases/download/1.14/gosu-arm64'; \
            sha256='73244a858f5514a927a0f2510d533b4b57169b64d2aa3f9d98d92a7a7df80cea'; \
            ;; \
        *) echo "Unsupported architecture: ${ARCH}"; exit 1 ;; \
    esac; \
    curl -L ${url} -o gosu ; \
    echo "${sha256} *gosu" | sha256sum -c - ; \
    chmod +x gosu ; \
    mv gosu /usr/local/bin/gosu

ENV JAVA_HOME=/usr/lib/jvm/java
ENV PATH $PATH:/hadoop/bin

RUN groupadd --gid 1000 hdfs && groupadd --gid 1001 hadoop && groupadd --gid 1002 yarn \
&& useradd -u 1000 -g hdfs -G hadoop hdfs \
&& useradd -u 1001 -g yarn -G hadoop yarn \
&& useradd systest && useradd systest2 && useradd systest3

RUN mkdir -p /mnt/data && chmod 1777 /mnt/data \
  && mkdir -p /etc/hadoop/conf \
  && mkdir -p /var/log/hadoop && chmod 1777 /var/log/hadoop \
  && mkdir -p /opt/security

ENV HADOOP_LOG_DIR=/var/log/hadoop
ENV HADOOP_CONF_DIR=/etc/hadoop/conf

COPY ./include/* /opt/
RUN chmod 755 /opt/* \
  && rm -f /etc/krb5.conf && cp /opt/krb5.conf /etc/krb5.conf

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/opt/start.sh"]
