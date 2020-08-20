FROM centos:centos7
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y sudo python2-pip wget nmap-ncat jq java-11-openjdk java-11-openjdk-devel ruby

# Setup gosu for easier command execution
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-amd64.asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && rm -r /root/.gnupg/ \
    && chmod +x /usr/local/bin/gosu

ENV JAVA_HOME=/usr/lib/jvm/java
ENV PATH $PATH:/hadoop/bin

RUN groupadd --gid 1000 hdfs && groupadd --gid 1001 hadoop && groupadd --gid 1002 yarn \
&& useradd -u 1000 -g hdfs -G hadoop hdfs \
&& useradd -u 1001 -g yarn -G hadoop yarn \
&& useradd systest && useradd systest2 && useradd systest3

RUN mkdir -p /mnt/data && chmod 1777 /mnt/data && mkdir -p /etc/hadoop/conf && mkdir -p /var/log/hadoop && chmod 1777 /var/log/hadoop

ENV HADOOP_LOG_DIR=/var/log/hadoop
ENV HADOOP_CONF_DIR=/etc/hadoop/conf

ADD env2conf.rb /opt/env2conf.rb
RUN chmod 755 /opt/env2conf.rb

ADD start.sh /opt/start.sh
RUN chmod 755 /opt/start.sh
ENTRYPOINT ["/opt/start.sh"]
