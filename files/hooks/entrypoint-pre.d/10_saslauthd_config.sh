#!/bin/bash

die () {
  echo $1
  exit 1
}

[ -z "${LDAP_SERVERS}" ] && die "LDAP_SERVERS not specified"
[ -z "${LDAP_SEARCH_BASE}" ] && die "LDAP_SEARCH_BASE not specified"
[ -z "${LDAP_FILTER}" ] && die "LDAP_FILTER not specified"
[ -z "${LDAP_BIND_DN}" ] && die "LDAP_BIND_DN not specified"
[ -z "${LDAP_BIND_PW}" ] && die "LDAP_BIND_PW not specified"
[ -z "${LDAP_PROTOCOL}" ] && die "LDAP_PROTOCOL not specified"

cat <<EOF > /etc/saslauthd.conf
ldap_auth_method: bind
ldap_default_domain: ipa.${DOMAIN}
ldap_default_realm: ipa.${DOMAIN}
ldap_servers: $(for s in ${LDAP_SERVERS}; do echo -n "${LDAP_PROTOCOL}://${s} "; done)
ldap_search_base: ${LDAP_SEARCH_BASE}
ldap_filter: ${LDAP_FILTER}
ldap_bind_dn: ${LDAP_BIND_DN}
ldap_bind_pw: ${LDAP_BIND_PW}
ldap_start_tls: yes
ldap_tls_cacert_file: ${LDAP_CA_FILE}
ldap_cache_ttl: 30
EOF
