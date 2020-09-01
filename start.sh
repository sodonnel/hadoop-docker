#!/usr/bin/env bash
set -e

waitFor() {
  local host="$1"
  local port="$2"
  echo "Waiting for the service ${host}:$port"
  for i in `seq ${WAITFOR_TIMEOUT:-300} -1 0` ; do
    set +e
    nc -z "$host" "$port" > /dev/null 2>&1
    result=$?
    set -e
    if [ $result -eq 0 ] ; then
      break
    fi
    sleep 1
  done
  if [ "$i" -eq 0 ]; then
     echo "Waiting for service ${host}:$port is timed out." >&2
     exit 1
  fi
}

RUN_AS=root

if [ -n "$RUN_AS_USER" ]; then
  chown $RUN_AS_USER /mnt/data && chmod 755 /mnt/data
  chown $RUN_AS_USER /var/log/hadoop && chmod 755 /var/log/hadoop
  RUN_AS=$RUN_AS_USER
fi

# Setup the config files from the environment
/opt/env2conf.rb

if [ ! -f /etc/hadoop/conf/log4j.properties ]; then
  cp /hadoop/etc/hadoop/log4j.properties /etc/hadoop/conf/log4j.properties
fi

if [ -n "$KERBEROS_ENABLED" ]; then
  waitFor $KDC_HOST $KDC_PORT
  /opt/create-keytabs.rb "$KERBEROS_PRINCIPALS"
fi

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
#
# Note with this implementation, a given service can only wait
# on one other port.
if [ ! -z "$WAITFOR" ]; then
  WAITFOR_HOST=$(printf "%s\n" "$WAITFOR"| cut -d : -f 1)
  WAITFOR_PORT=$(printf "%s\n" "$WAITFOR"| cut -d : -f 2)
  waitFor $WAITFOR_HOST $WAITFOR_PORT
fi

if [ -n "$ENSURE_NAMENODE_DIR" ]; then
  if [ ! -d "$ENSURE_NAMENODE_DIR" ]; then
    gosu $RUN_AS /hadoop/bin/hdfs namenode -format -force
  fi
fi

if [ -n "$ENSURE_SECONDARY_NAMENODE_DIR" ]; then
  if [ ! -d "$ENSURE_SECONDARY_NAMENODE_DIR" ]; then
    gosu $RUN_AS /hadoop/bin/hdfs secondarynamenode -format -force
  fi
fi

if [ -n "$BOOTSTRAP_STANDBY_DIR" ]; then
  if [ ! -d "$BOOTSTRAP_STANDBY_DIR" ]; then
    gosu $RUN_AS /hadoop/bin/hdfs namenode -bootstrapStandby
  fi
fi

# With a HA build that does not use ZK or ZKFC, use this to set a given NN active
# eg, MAKE_NN_ACTIVE=nn1
if [ ! -z "$MAKE_NN_ACTIVE" ]; then
  gosu $RUN_AS /hadoop/bin/hdfs haadmin -transitionToActive --forceactive "$MAKE_NN_ACTIVE"
fi

# To ensure ZKFC is formatted only once pass ENSURE_ZKFC_FORMATTED=/path/to/file
# where /path/to/file is a file on a persistent volume that indicates it has already
# been formatted. This avoid formatting again on restart.
if [ -n "$ENSURE_ZKFC_FORMATTED" ]; then
  if [ ! -f "$ENSURE_ZKFC_FORMATTED" ]; then
    gosu $RUN_AS /hadoop/bin/hdfs zkfc -formatZK && touch $ENSURE_ZKFC_FORMATTED
  fi
fi

# To start ZKFC pass ENSURE_ZKFC=1 in the compose environment
if [ -n "$ENSURE_ZKFC" ]; then
  gosu $RUN_AS /hadoop/bin/hdfs --daemon start zkfc
fi

gosu $RUN_AS "$@"
