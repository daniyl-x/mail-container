#!/bin/sh


HOME_MAILBOX=${HOME_MAILBOX:-"Maildir/"}
MASQUERADE_DOMAINS=${MASQUERADE_DOMAINS-}
MYDOMAIN=${MYDOMAIN-}
MYHOSTNAME=${MYHOSTNAME:-"mail.\$mydomain"}
MYORIGIN=${MYORIGIN:-"\$mydomain"}
TLS_CERT_FILE=${TLS_CERT_FILE-}
TLS_KEY_FILE=${TLS_KEY_FILE-}

POSTMASTER=${POSTMASTER-}


_ERRORS=0
for _VAR in "MYDOMAIN" "TLS_CERT_FILE" "TLS_KEY_FILE"; do
    if [ -z "$(eval echo \$$_VAR)" ]; then
        echo "[ERROR] Variable ${_VAR} should not be empty"
        _ERRORS=1
    fi
done

if [ "$_ERRORS" -ne 0 ]; then
    return 1
fi


postconf -e "mydomain = ${MYDOMAIN}"
postconf -e "myorigin = ${MYORIGIN}"
postconf -e "myhostname = ${MYHOSTNAME}"
postconf -e "masquerade_domains = ${MASQUERADE_DOMAINS}"
postconf -e "home_mailbox = ${HOME_MAILBOX}"
postconf -e "smtpd_tls_cert_file = ${TLS_CERT_FILE}"
postconf -e "smtpd_tls_key_file = ${TLS_KEY_FILE}"

postconf -e "smtp_tls_security_level = may"
postconf -e "smtpd_tls_security_level = may"
postconf -e "smtpd_tls_note_starttls_offer = yes"
postconf -e "smtpd_tls_loglevel = 1"
postconf -e "smtpd_tls_recieved_header = yes"

postconf -e "smtpd_sasl_type = dovecot"
postconf -e "smtpd_sasl_path = private/auth"
postconf -e "smtpd_sasl_local_domain ="
postconf -e "smtpd_sasl_security_options = noanonymous"
postconf -e "broken_sasl_auth_clients = yes"
postconf -e "smtpd_sasl_auth_enable = yes"
postconf -e "smtpd_sasl_recipient_restrictions = permit_sasl_authenticated,\
    permit_mynetworks,reject_unauth_destination"


if [ -n "$POSTMASTER" ] && ! grep "$POSTMASTER" /etc/aliases; then
    echo "root: ${POSTMASTER}" >> /etc/aliases
fi
newaliases


service postfix start
service dovecot start
while sleep 3; do
    service postfix status
    service dovecot status
done

