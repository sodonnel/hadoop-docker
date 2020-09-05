#!/bin/bash

set -e

generate_ca () {
  root="/data/ca"
  if [ -d $root ]; then
    return
  fi
    
  current_dir=$PWD

  mkdir -p $root
  mkdir $root/certs
  mkdir $root/clr
  mkdir $root/newcerts

  chmod -R 755 $root

  mkdir $root/private
  chmod 700 $root/private

  touch $root/index.txt
  chmod 644 $root/index.txt

  echo "1000" > $root/serial
  chmod 644 $root/serial

  cp /opt/root_openssl.cnf $root/openssl.cnf

  cd $root

  openssl req \
    -config openssl.cnf \
    -new \
    -newkey rsa:4096 \
    -days 750 \
    -nodes \
    -x509 \
    -subj "/C=GB/ST=England/L=London/O=hadoop_inc/OU=hadoop_inc_root_ca/CN=Apache Hadoop" \
    -keyout private/ca.key.pem \
   -out certs/ca.cert.pem

  cd $current_dir

  chmod 400 $root/private/ca.key.pem
  chmod 444 $root/certs/ca.cert.pem

  mkdir $root/intermediate
  mkdir $root/intermediate/certs
  mkdir $root/intermediate/clr
  mkdir $root/intermediate/csr
  mkdir $root/intermediate/newcerts

  chmod -R 755 $root/intermediate

  mkdir $root/intermediate/private
  chmod 700 $root/intermediate/private

  touch $root/intermediate/index.txt
  chmod 644 $root/intermediate/index.txt

  echo "1000" > $root/intermediate/serial
  chmod 644 $root/intermediate/serial

  echo "1000" > $root/intermediate/clrnumber
  chmod 644 $root/intermediate/clrnumber

  cp /opt/intermediate_openssl.cnf $root/intermediate/openssl.cnf

  cd $root
  openssl req \
    -config intermediate/openssl.cnf \
    -new \
    -newkey rsa:4096 \
    -sha256 \
    -nodes \
    -subj "/C=GB/ST=England/L=London/O=hadoop_inc/OU=hadoop_inc_root_ca/CN=Apache Hadoop Intermed" \
    -keyout intermediate/private/intermediate.key.pem \
    -out intermediate/csr/intermediate.csr.pem

  chmod 400 intermediate/private/intermediate.key.pem


  openssl ca \
    -batch \
    -config openssl.cnf \
    -extensions v3_intermediate_ca \
    -days 3650 \
    -notext \
    -md sha256 \
    -in intermediate/csr/intermediate.csr.pem \
    -out intermediate/certs/intermediate.cert.pem

  cat intermediate/certs/intermediate.cert.pem certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem

  cd $current_dir
}

generate_ca

exec ruby /opt/app.rb
