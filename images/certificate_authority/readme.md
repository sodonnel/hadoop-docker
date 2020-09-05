# Certificate Authority

Creates a Docker image for a simple OpenSSL based certificate authority.

This is intended for testing, rather than production - no effort has been taken to check for security flaws!

Upon starting the container, a root and intermediate certificate are generated for the CA.

Then a simple http endpoint is created which allows the root and intermediate trust certificates to be downloaded:

    # Get the public intermediate certificate for a truststore, as a pem file
    http://<hostname>:8080/cacert

    # Get the public root and intermediate certs for a trustore in a single pem file
    http://<hostname>:8080/cachain

A further http endpoint is available to sign a certificate at:

    http://<hostname>:8080/sign

To use this, simply post a Certificate Signing Request (CSR) as the request body and the certificate will be created and returned in the response as a pem file, eg:

```
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
  curl -X POST --data-binary @csr.pem -o cert.pem http://ca-host:8080/sign

```

## Configuration

The http server currently runs on port 8080 - there is no way to configure this right now.

All data is stored under /data and generated the first time the container starts. You can therefore mount a volume at /data to perserve data between containers if required.
