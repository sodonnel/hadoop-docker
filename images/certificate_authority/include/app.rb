require 'sinatra/base'

class CertSigner < Sinatra::Base
  
  CA_ROOT="/data/ca/intermediate"

  set :port, 8080
  set :bind, '0.0.0.0'

  # Returns just the intermediate CA file
  get "/cacert" do
    send_file "#{CA_ROOT}/certs/intermediate.cert.pem", :filename => "cacert.pem", :type => 'Application/octet-stream'
  end

  # Returns the CA chain file, containing the root and intermediate certs
  get "/cachain" do
    send_file "#{CA_ROOT}/certs/ca-chain.cert.pem", :filename => "ca-chain.pem", :type => 'Application/octet-stream'
  end

  # The request body should be a CSR and it will be signed by
  # the CA and a certificate returned in the response.
  post "/sign" do
    csr = request.body.read
    uuid = SecureRandom.uuid
    File.open("#{CA_ROOT}/csr/#{uuid}", 'w') { |f| f.write(csr) }

    res = system("openssl ca -config #{CA_ROOT}/openssl.cnf -batch \
        -extensions server_cert -days 375 -notext -md sha256 \
        -in #{CA_ROOT}/csr/#{uuid} \
        -out #{CA_ROOT}/certs/#{uuid}.cert.pem")
    if res
      send_file "#{CA_ROOT}/certs/#{uuid}.cert.pem", :filename => "#{uuid}.cert.pem", :type => 'Application/octet-stream'
    else
      status 500
    end

  end
  
end

run CertSigner.run!
