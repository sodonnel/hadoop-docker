The build image is based on Centos 7 latest (centos:centos7 on DockerHub). Building the image takes quite a long time, mainly due to needing to compile protobuf.

To build the image, run the following in this directory:

```
docker image build -t hdfs-build-test:1.0 .
```

Once this image is built locally, we can use it to compile Hadoop. The way this works is:

 * You must checkout the Hadoop repo
 * Mount that Hadoop repo as a host mount so the container can access it for both read and write
 * Run the build so the compiled binaries are written to the host mount, which would be <hadoop_repo>/hadoop-dist/target in this case
 * The build then remains on the host and not in the container

The docker container used for the compile is ephemeral, and compiling Hadoop requires downloading quite a lot of dependencies from Maven. Therefore it can also make sense to mount a host maven cache into the container so the dependencies can be reused (if you plan to build many times).

To compile with a local maven repo mvn-repo located at `../../docker-mvn-repo`, and with the hadoop repo at `../../hadoop` first ensure that path exists and run:

```
docker run -it -v `pwd`/../../hadoop:/hadoop -v `pwd`/../../docker-mvn/repo:/mvn-repo -w /hadoop hdfs-build-test:1.0 mvn -Dmaven.repo.local=/mvn-repo/repository clean package -Pdist,native -DskipTests -Dmaven.javadoc.skip=true
```

The above command creates a build with native extensions, which is significantly slower. To create a non-native build simply change `-Pdist,native` to `-Pdist`.

If you need to set any custom Maven settings (eg settings.xml), you can also change where maven looks for the settings.xml by passing `-Dmaven.home` to the mvn command and placing the settings.xml in the repo folder mounted from the host.

To make all this easier you can simply run the `build.sh` script in this directory. It will expect:

* The hadoop repo to exist at ../../hadoop or in the location specified in the HADOOP_REPO environment variable
* It will create a local mvn repo at ../../docker-mvn/repo or in the location specified in the MVN_REPO environment variable, which will be used when building hadoop.
* It will create a native build by default, unless you pass `./build.sh no_native`.

See the header in the script for more details.
