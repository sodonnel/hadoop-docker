# Hadoop Docker

This repo contains a few docker receipies to get Hadoop clusters running in Docker. This is intended for testing and experimentation, rather than production.

## The Docker File

The dockerfile is based on Centos with a few basic packages, including java-11-openjdk. There are 4 important paths on the image:

* /mnt/data - Any container data is persisted here, eg namenode images, edits, datanode blocks etc. This is an anonymous volume so data is persisted between container restarts.
* /var/log/hadoop - All logs are directed here. This is an anonymous volume so data is persisted between restarts.
* /etc/hadoop/conf - The HDFS configuration is mounted here, as a host mount from this repo.
* /hadoop - A build of Hadoop is mounted here, as a host mount.


## start.sh

Each container is started using the start.sh script at the root of this repo. It checks for the presence of certain environment variables to allow a container to initialize (eg format namenode), wait on another service to come up etc. Then it executes the docker container command. These environment variables can be passed to Docker commands or specified within docker-compose files.





