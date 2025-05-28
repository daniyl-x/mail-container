FROM debian:stable-slim

RUN apt-get update && apt-get install --no-install-recommends -y \
    postfix dovecot-core && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man

COPY config/aliases /etc/
COPY config/10-master.conf /etc/dovecot/conf.d/
COPY config/10-auth.conf /etc/dovecot/conf.d/

COPY docker-entrypoint.sh .

EXPOSE 25

ENTRYPOINT ["./docker-entrypoint.sh"]

