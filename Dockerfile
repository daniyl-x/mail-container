FROM debian:stable-slim

RUN apt-get update && apt-get install --no-install-recommends -y \
    postfix && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man

COPY docker-entrypoint.sh .

ENTRYPOINT ["./docker-entrypoint.sh"]

