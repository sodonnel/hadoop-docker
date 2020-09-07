# The relative path to the Hadoop Repo needs to be set in the env variable HADOOP_REPO
# otherwise the default of ../../hadoop will be used.
#
# By default a local mvn repo is created in ../../docker-mvn/repo and the container
# will use that location to storage mvn artifacts. This makes it faster if you need to
# do several builds as the repo can be reused. Override the default by setting the
# environment variable HADOOP_MVN_REPO to a different relative path.
#
# By default a native build is created. To avoid that pass no_native to the script, eg
#
#    ./build.sh --no_native
#
# The default docker image is hdfs-build:3.7.1, corresponding to the docker image 
# containing protobuf 3.7.1. It use a different protobuf version (and assuming the image
# exists) run the script like:
#
#    ./build.sh --proto_version=2.5.0
#
# TODO:
#   Allow a switch to enable or disable the local mvn repo, ie allow it to be created
#      inside the container.
#   Allow setting mvn home to be able to pass a custom maven settings.xml to the container  

set -e

REPO_LOCATION=${HADOOP_REPO:-../../hadoop}
MVN_REPO=${HADOOP_MVN_REPO:-../../docker-mvn/repo}

if [[ "$REPO_LOCATION" != /* ]]; then
    REPO_LOCATION=`pwd`/$REPO_LOCATION
fi

if [[ "$MVN_REPO" != /* ]]; then
    MVN_REPO=`pwd`/$MVN_REPO
fi

BUILD_OPTION="-Pdist,native"
PROTO_VERSION="3.7.1"

while [ $# -gt 0 ]; do
  case "$1" in
    --proto_version=*)
      PROTO_VERSION="${1#*=}"
      echo "Using protobuf version $PROTO_VERSION"
      ;;
    --no_native)
      echo "Creating a non native build"
      BUILD_OPTION="-Pdist"
      ;;
    *)
      printf "***************************\n"
      printf "* Error: Invalid argument.*\n"
      printf "***************************\n"
      exit 1
  esac
  shift
done

if [[ ! -d $REPO_LOCATION ]]; then
    echo "Hadoop Repo is not present at $REPO_LOCATION"
    exit 1
fi

if [[ ! -d $MVN_REPO ]]; then
  echo "Creating maven repo at $MVN_REPO"
  mkdir -p $MVN_REPO
fi

docker run -it -v ${REPO_LOCATION}:/hadoop -v ${MVN_REPO}:/mvn-repo -w /hadoop hdfs-build:$PROTO_VERSION mvn -Dmaven.repo.local=/mvn-repo/repository clean package ${BUILD_OPTION} -DskipTests -Dmaven.javadoc.skip=true
