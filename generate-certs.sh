#!/bin/bash

# Expect to receive the CA host as $1 and port as $2
fqdn=$(hostname -f)
CA="http://$1:$2"
target="/opt/security"

current_dir=$PWD
cd $target


curlWithRetry() {
  local options=$1
  local url=$2

  for (( var = 0; var < 10; var++ )); do
    local status=$(curl $options --connect-timeout 5 --write-out %{response_code} --silent ${url})
    if [ $status == 200 ]; then
      return 0
    fi
    echo "Curl returned a status code of $status - retrying upto 10 times"
    sleep 1
  done
  echo "Curl did not receive a 200 response code after 10 attempts"
  return 1
}

if [ ! -f generated ]; then

  # Generate the private key and CSR
  openssl req \
    -new \
    -newkey rsa:2048 \
    -sha256 \
    -nodes \
    -subj "/C=GB/ST=England/L=London/O=hadoop_inc/OU=server_cert/CN=$fqdn" \
    -keyout key.pem \
    -out csr.pem

  # Sign the cert at the CA
  curlWithRetry "-X POST --data-binary @csr.pem -o cert.pem" "$CA/sign"

  # Download the CA trusted certs
  curlWithRetry "-o cacert.pem"  "$CA/cacert"
  curlWithRetry "-o ca-chain.pem" "$CA/cachain"

  # Generate a pkcs12 file that contains the private key, cert and trust chain
  openssl pkcs12 -export -in cert.pem -inkey key.pem \
    -passin pass:password -out cert.p12 \
    -name $fqdn -CAfile ca-chain.pem \
    -caname Hadoop_inc_intermed -passout pass:password -chain

  # Using the pkcs12 file, create a java keystore
  keytool -importkeystore -deststorepass password -destkeystore host.keystore \
    -srckeystore cert.p12 \
    -srcstoretype PKCS12 -alias $fqdn \
    -srcstorepass password

  # Create a trust store using the CA trusted certs
  keytool -importcert -noprompt -keystore ca.truststore -alias CA-cert -storepass password -file cacert.pem

  touch generated
fi

cd $current_dir
