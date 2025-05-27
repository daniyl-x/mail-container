FROM debian:stable-slim

RUN apt-get update && apt-get install --no-install-recommends -y \
    postfix && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man

COPY config/aliases /etc/aliases
COPY docker-entrypoint.sh .

EXPOSE 25

ENTRYPOINT ["./docker-entrypoint.sh"]

