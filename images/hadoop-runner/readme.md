# hadoop-runner

Provides an image which is able to run a hadoop build. It is based on Centos with a few basic packages, including java-11-openjdk. There are 4 important paths on the image:

* /mnt/data - Any container data is persisted here, eg namenode images, edits, datanode blocks etc. This is an anonymous volume so data is persisted between container restarts.
* /var/log/hadoop - In general Hadoop logs go to stdout, so they can be monitored in docker. However any logs not written to stdout should go here.
* /etc/hadoop/conf - The HDFS configuration is generated from environment variables in this location.
* /hadoop - A build of Hadoop is mounted here, as a host mount.

## Build the Docker Image

Run the following to build and tag the image from the root of this repo:

    docker build . --tag hadoop-docker:latest

## start.sh

Each container is started using the start.sh script at the root of this repo. It checks for the presence of certain environment variables to allow a container to initialize (eg format namenode), wait on another service to come up etc. Then it executes the docker container command. These environment variables can be passed to Docker commands or specified within docker-compose files.

## Generating config

The Ruby script in include/env2conf.rb uses environment variables defined when the container is started to create the configuration files the container needs.

It first scans for variables named like "ENV2CONF_", eg:

    ENV2CONF_hdfs-site.xml=/etc/hadoop/conf

This says a config file called hdfs-site.xml should be created in /etc/hadoop/conf. The script will then scan for further environment variables starting with "hdfs-site.xml_", eg:

    hdfs-site.xml_dfs.namenode.name.dir=/mnt/data/nn

This says, a config parameter "dfs.namenode.name.dir" with a value of "/mnt/data/nn" should be written into the hdfs-site.xml config file.

If the value of a variable contains a string enclosed in double % symbols, eg:

    yarn-site.xml_yarn.nodemanager.remote-app-log-dir=%%core-site.xml_fs.defaultFS%%/var/log/hadoop-yarn/apps

Then the value of "%%core-site.xml_fs.defaultFS%%" will be replaced with the real environment value before emitting it to the configuration. You cannot nest these replacements - if the referenced variable also contains a replacement string, it will not get replaced.

Only Hadoop XML config is supported at the current time.
