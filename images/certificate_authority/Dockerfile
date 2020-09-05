FROM alpine:latest

RUN apk add sudo bash wget curl openssl dumb-init ruby ruby-dev ruby-json alpine-sdk \
  && gem install thin --no-document \
  && gem install etc --no-document \
  && gem install sinatra --version=2.0.8.1 --no-document \
  && apk del alpine-sdk \
  && rm -Rf /tmp/* /var/lib/cache/apk/*

RUN mkdir -p /data && mkdir -p /opt

COPY ./include/* /opt/

RUN chmod 755 /opt/start.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/start.sh"]
