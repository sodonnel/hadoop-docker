#!/usr/bin/env bash
set -e

#
# You can wait for an other TCP port with these settings.
#
# Example:
#
# export WAITFOR=localhost:9878
#
# With an optional parameter, you can also set the maximum
# time of waiting with (in seconds) with WAITFOR_TIMEOUT.
# (The default is 300 seconds / 5 minutes.)
if [ ! -z "$WAITFOR" ]; then
  echo "Waiting for the service $WAITFOR"
  WAITFOR_HOST=$(printf "%s\n" "$WAITFOR"| cut -d : -f 1)
  WAITFOR_PORT=$(printf "%s\n" "$WAITFOR"| cut -d : -f 2)
  for i in `seq ${WAITFOR_TIMEOUT:-300} -1 0` ; do
    set +e
    nc -z "$WAITFOR_HOST" "$WAITFOR_PORT" > /dev/null 2>&1
    result=$?
    set -e
    if [ $result -eq 0 ] ; then
      break
    fi
    sleep 1
  done
  if [ "$i" -eq 0 ]; then
     echo "Waiting for service $WAITFOR is timed out." >&2
     exit 1
  f
  fi
fi

if [ -n "$ENSURE_NAMENODE_DIR" ]; then
  if [ ! -d "$ENSURE_NAMENODE_DIR" ]; then
    /hadoop/bin/hdfs namenode -format -force
  fi
fi

if [ -n "$ENSURE_SECONDARY_NAMENODE_DIR" ]; then
  if [ ! -d "$ENSURE_SECONDARY_NAMENODE_DIR" ]; then
    /hadoop/bin/hdfs secondarynamenode -format -force
  fi
fi

if [ -n "$BOOTSTRAP_STANDBY_DIR" ]; then
  if [ ! -d "$BOOTSTRAP_STANDBY_DIR" ]; then
    /hadoop/bin/hdfs namenode -bootstrapStandby
  fi
fi

if [ ! -z "$MAKE_NN_ACTIVE" ]; then
  /hadoop/bin/hdfs haadmin -transitionToActive --forceactive "$MAKE_NN_ACTIVE"
fi

"$@"
