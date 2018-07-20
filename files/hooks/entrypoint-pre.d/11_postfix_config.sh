#!/bin/bash

die() {
  echo $1
  exit 1
}

postconf -e "myhostname = ${DOMAIN}"
postconf -e "smtp_fallback_relay = [smtp-01.mgmt.${DOMAIN}]"

# SSL config
if ! [ -z $SSL_CERT_FILE ] && ! [ -z $SSL_KEY_FILE ]; then

  [ ! -f $SSL_CERT_FILE ] && die "SSL_CERT_FILE: '${SSL_CERT_FILE}' not accessible."
  [ ! -f $SSL_KEY_FILE ] && die "SSL_KEY_FILE: '${SSL_KEY_FILE}' not accessible."
  [ ! -z $SSL_CA_FILE ] && [ ! -f $SSL_CA_FILE ] && die "SSL_CA_FILE: '${SSL_CA_FILE}' not accessible."

  if [ ! -z $SSL_CA_FILE ]; then
    openssl verify -CAfile ${SSL_CA_FILE} ${SSL_CERT_FILE}
    [ "$?" != "0" ] && die "Verification of the SSL certificate failed"
  fi
  certmod=$(openssl x509 -noout -modulus -in $SSL_CERT_FILE)
  keymod=$(openssl rsa -noout -modulus -in $SSL_KEY_FILE)
  [ "$certmod" != "$keymod" ] && die "The SSL_CERT_FILE and SSL_KEY_FILE files do not belong together."


  postconf -e "smtpd_tls_security_level = may"
  postconf -e "smtpd_tls_ciphers = high"
  postconf -e "smtpd_tls_cert_file = ${SSL_CERT_FILE}"
  postconf -e "smtpd_tls_key_file = ${SSL_KEY_FILE}"

  if [ ! -z $SSL_CA_FILE ]; then
    postconf -e "smtpd_tls_CAfile = ${SSL_CA_FILE}"
  else
    postconf -e "smtpd_tls_CApath = /etc/ssl/certs"
  fi
fi
