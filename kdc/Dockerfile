FROM alpine:latest

ENV KRB5_KDC_PROFILE /etc/kdc.conf

RUN mkdir -p /data && mkdir -p /var/lib && ln -s /data /var/lib/krb5kdc

RUN apk add bash wget krb5 krb5-libs krb5-dev krb5-server dumb-init

ADD ./kdc.conf /etc/kdc.conf

ADD ./krb5.conf /etc/krb5.conf

RUN chmod 644 /etc/kdc.conf && chmod 644 /etc/krb5.conf

ADD ./start.sh /start.sh

RUN chmod 644 /etc/kdc.conf && chmod 644 /etc/krb5.conf && chmod 755 /start.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/start.sh"]
