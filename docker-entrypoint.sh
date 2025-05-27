#!/bin/sh


MYORIGIN="example.com"
MASQUERADE_DOMAINS=${MASQUERADE_DOMAINS-}


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


service postfix start
while sleep 1; do
    service postfix status
done

