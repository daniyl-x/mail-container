#!/bin/sh


MASQUERADE_DOMAINS=${MASQUERADE_DOMAINS-}
MYDOMAIN=${MYDOMAIN-}
MYHOSTNAME=${MYHOSTNAME:-"mail.\$mydomain"}
MYORIGIN=${MYORIGIN:-"\$mydomain"}
NET_INTERFACES=${NET_INTERFACES:-"loopback-only"}
TLS_CERT_FILE=${TLS_CERT_FILE-}
TLS_KEY_FILE=${TLS_KEY_FILE-}

POSTMASTER=${POSTMASTER-}


if [ -z "$MYDOMAIN" ]; then
    echo "[ERROR] No domain name was passed. Use MYDOMAIN variable to do this"
    return 1
fi

postconf -e "mydomain = ${MYDOMAIN}"
postconf -e "myorigin = ${MYORIGIN}"
postconf -e "myhostname = ${MYHOSTNAME}"
postconf -e "inet_interfaces = ${NET_INTERFACES}"
postconf -e "masquerade_domains = ${MASQUERADE_DOMAINS}"

if [ -n "$TLS_CERT_FILE" ] && [ -n "$TLS_KEY_FILE" ]; then
    postconf -e "smtpd_tls_cert_file = ${TLS_CERT_FILE}"
    postconf -e "smtpd_tls_key_file = ${TLS_KEY_FILE}"
fi


if [ -n "$POSTMASTER" ] && ! grep "$POSTMASTER" /etc/aliases; then
    echo "root: ${POSTMASTER}" >> /etc/aliases
fi
newaliases


service postfix start
while sleep 1; do
    service postfix status
done

