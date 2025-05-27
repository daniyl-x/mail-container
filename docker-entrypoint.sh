#!/bin/sh


MASQUERADE_DOMAINS=${MASQUERADE_DOMAINS-}
MYDOMAIN=${MYDOMAIN-}
MYHOSTNAME=${MYHOSTNAME:-"mail.\$mydomain"}
MYORIGIN=${MYORIGIN:-"\$mydomain"}
NET_INTERFACES=${NET_INTERFACES:-"loopback-only"}
TLS_CERT_FILE=${TLS_CERT_FILE-}
TLS_KEY_FILE=${TLS_KEY_FILE-}

POSTMASTER=${POSTMASTER-}


set_opt(){
    if grep -E "^#?${2} ="; then
        sed -Ei "s/^#?${2} = .*$/${2} = ${3}/" "$1"
    else
        echo "${2} = ${3}" >> $1
    fi
}

_CONF="/etc/postfix/main.cf"
_TMPFILE="$(mktemp)"
cp "$_CONF" "$_TMPFILE"

if [ -z "$MYDOMAIN" ]; then
    echo "[ERROR] No domain name was passed. Use MYDOMAIN variable to do this"
    return 1
fi

set_opt "$_TMPFILE" "mydomain" "$MYDOMAIN"
set_opt "$_TMPFILE" "myorigin" "$MYORIGIN"
set_opt "$_TMPFILE" "myhostname" "$MYHOSTNAME"
set_opt "$_TMPFILE" "inet_interfaces" "$NET_INTERFACES"
set_opt "$_TMPFILE" "masquerade_domains" "$MASQUERADE_DOMAINS"

if [ -n "$TLS_CERT_FILE" ] && [ -n "$TLS_KEY_FILE" ]; then
    set_opt "$_TMPFILE" "smtpd_tls_cert_file" "$TLS_CERT_FILE"
    set_opt "$_TMPFILE" "smtpd_tls_key_file" "$TLS_KEY_FILE"
fi

diff -q "$_CONF" "$_TMPFILE" || cp "$_TMPFILE" "$_CONF"


if [ -n "$POSTMASTER" ] && \
    ! grep "$POSTMASTER" /etc/aliases; then
    echo "root: ${POSTMASTER}" >> /etc/aliases
fi
newaliases


service postfix start
while sleep 1; do
    service postfix status
done

