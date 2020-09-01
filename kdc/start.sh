#!/bin/bash

set -e

if [ ! -f /var/lib/krb5kdc/principal ]; then
  /usr/sbin/kdb5_util create -s -W -P password
fi

if [ ! -f /var/lib/krb5kdc/created_principal ]; then
  /usr/sbin/kadmin.local -q "addprinc -pw password root/admin"
  touch /var/lib/krb5kdc/created_principal
fi

if [ ! -f /var/lib/krb5kdc/kadm5.acl ]; then
  echo "*/admin@EXAMPLE.COM  *" > /var/lib/krb5kdc/kadm5.acl  
fi

kadmind &
exec krb5kdc -n
# start kadmind and kdc
