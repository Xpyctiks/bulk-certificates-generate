#!/bin/env bash

if ! [[ -f "./domains.txt" ]]; then
    echo "domains.txt not found!"
    exit 1
elif ! [[ -s "./domains.txt" ]]; then
    echo "domains.txt is empty!"
    exit 1
fi

while read domain; do
	openssl ecparam -out ${domain}.key -name prime256v1 -genkey
${domain}.conf << EOF
[ req ]
default_bits       = 2048
distinguished_name = req_distinguished_name
req_extensions     = v3_req
#attributes        = req_attributes
x509_extensions = v3_req
prompt = no
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
[ req_distinguished_name ]
countryName                = UA
stateOrProvinceName        = KY
localityName               = Kyiv
organizationName           = Organization
organizationalUnitName     = ${domain} server
commonName                 = ${domain}
emailAddress               = admin@organization.com
[ v3_req ]
subjectAltName = @alt_names
[alt_names]
DNS.1   = ${domain}
EOF
	openssl req -new -key ${domain}.key -nodes -out ${domain}.csr -config ${domain}.conf -sha256
	openssl x509 -req -days 365 -in ${domain}.csr -CA ca.crt -CAkey ca.key -out ${domain}.crt -extfile ${domain}.conf -extensions v3_req
	rm ${domain}.conf
	rm ${domain}.csr
done <<< $(cat domains.txt)
