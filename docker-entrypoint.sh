#!/bin/sh


MYORIGIN="example.com"
MASQUERADE_DOMAINS=${MASQUERADE_DOMAINS-}
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

set_opt "$_TMPFILE" "myorigin" "$MYORIGIN"
set_opt "$_TMPFILE" "inet_interfaces" "loopback-only"
set_opt "$_TMPFILE" "masquerade_domains" "$MASQUERADE_DOMAINS"

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

