FROM centos:centos7
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y sudo python2-pip wget nmap-ncat jq java-11-openjdk
ENV JAVA_HOME=/usr/lib/jvm/jre/
ENV PATH $PATH:/hadoop/bin

#RUN groupadd --gid 1000 hadoop
#RUN useradd --uid 1000 hadoop --gid 100 --home /opt/hadoop
#RUN chmod 755 /opt/hadoop

RUN mkdir -p /mnt/data && chmod 1777 /mnt/data && mkdir -p /etc/hadoop/conf && mkdir -p /var/log/hadoop && chmod 1777 /var/log/hadoop

ENV HADOOP_LOG_DIR=/var/log/hadoop
ENV HADOOP_CONF_DIR=/etc/hadoop/conf

ADD start.sh /opt/start.sh
RUN chmod 755 /opt/start.sh
ENTRYPOINT ["/opt/start.sh"]