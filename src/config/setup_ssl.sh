#!/usr/bin/env bash

# To set up a self-signed SSL/HTTPS on a website you need to:
# 0. become the certificate authorateh (CA) (on your server/main device).
# 1. generate an SSL certificate based on the (CA) certificate you created.
# 2. make all your clients/other devices respect your own CA.

# In more details, analog to SSH, you create a private and public key pair.
# Next, each time someone visits your HTTPS website, you send them your public
# key. If they login to your HTTPS website, they encrypt their login username
# and password using your public key. Then your server receives the encrypted
# data and uses its own private key to decrypt it.

# The difference with SSH, is that besides encrypted data transmission, the
# browser of the person that visits your website also checks to see if they
# trust your server certificate authority(=a public certificate). Basically,
# the browser asks your website: "Who are you?", your server says: "I am this
# person (=self signed CA certificate)". Then the browser has its own list of
# people it knows. And if you self-sign, you are not in that list. That is why
# you need to make your clients add your self-signed CA certificate (so not the
# SSL certificate), to their list of "trusted Certificate Authorities".

# Now I can hear you thinking, "so my computer has a list of 6 billion friends
# (CA's) in it?". No, that would be inefficient. This is done hierarchically.
# There are root CA's, these sign certificates of certificate instances like,
# DigiCert, and Let's encrypt. And then Let's Encrypt gives normal users an
# (?SSL?) certificate, which any computer then knows comes from a trusted CA.

# Now this is where it gets interesting, I have some questions about this, in
# the past I read that some root CA was compromised, and cynical comments about
# how each root CA has probably a few three letter agency employees in it.
# What I do not yet know is, if one root CA is compromised whether all of its
# down-stream certificates are also automatically compromised, or not.

# Here is the list of certificates and their description:
# First you create your own certificate authority.
CA_PUBLIC_KEY_FILENAME="ca-key.pem"
CA_PRIVATE_KEY_FILENAME="ca.pem"

# Then you create a SSL certificate.
SSL_PUBLIC_KEY_FILENAME="cert-key.pem"
SSL_PRIVATE_KEY_FILENAME="cert.csr"

# Then create a sign-request (for your own CA to sign your own SSL certificate)
CA_SIGN_SSL_CERT_REQUEST_FILENAME="extfile.cnf"

# Then create the signed public SSL cert.
SIGNED_SSL_CERT_FILENAME="cert.pem"

setup_tor_ssl() {
  local onion_address="$1"

  # Create domains accepted by certificate.
  local domains
  domains="DNS:$onion_address"
  echo "domains=$domains.end_without_space"

  # Generate and apply certificate.
  generate_ca_cert "$ca_private_key_filename" "$CA_PUBLIC_KEY_FILENAME"
  generate_ssl_certificate "$CA_PUBLIC_KEY_FILENAME" "$CA_SIGN_SSL_CERT_REQUEST_FILENAME" "$SIGNED_SSL_CERT_FILENAME" "$SSL_PRIVATE_KEY_FILENAME" "$SSL_PUBLIC_KEY_FILENAME" "$domains"
  install_the_ca_cert_as_a_trusted_root_ca "$CA_PRIVATE_KEY_FILENAME"
}

generate_ca_cert() {
  local ca_private_key_filename="$1"
  local ca_public_key_filename="$2"

  # Generate RSA
  openssl genrsa -aes256 -out "$ca_public_key_filename" 4096

  # Generate a public CA Cert
  openssl req -new -x509 -sha256 -days 365 -key "$ca_public_key_filename" -out "$ca_private_key_filename"
}

generate_ssl_certificate() {
  local ca_public_key_filename="$1"
  local ca_sign_ssl_cert_request_filename="$2"
  local signed_ssl_cert_filename="$3"
  local ssl_private_key_filename="$4"
  local ssl_public_key_filename="$5"
  local domains="$6"
  # Example supported domains:
  # DNS:your-dns.record,IP:257.10.10.1

  # Create a RSA key
  openssl genrsa -out "$ssl_public_key_filename" 4096

  # Create a Certificate Signing Request (CSR)
  openssl req -new -sha256 -subj "/CN=yourcn" -key "$ssl_public_key_filename" -out "$ssl_private_key_filename"
  # Create a `extfile` with all the alternative names
  echo "subjectAltName=$domains" >>"$ca_sign_ssl_cert_request_filename"

  # optional
  #echo extendedKeyUsage = serverAuth >> "$ca_sign_ssl_cert_request_filename"

  # Create the certificate
  openssl x509 -req -sha256 -days 365 -in "$ssl_private_key_filename" -CA "$ca_private_key_filename" -CAkey "$ca_public_key_filename" -out "$signed_ssl_cert_filename" -extfile "$ca_sign_ssl_cert_request_filename" -CAcreateserial
}

verify_certificates() {
  openssl verify -CAfile "$ca_private_key_filename" -verbose "$signed_ssl_cert_filename"
}

install_the_ca_cert_as_a_trusted_root_ca() {
  local ca_private_key_filename="$1"

  # TODO: Verify target directory exists.
  # On Debian & Derivatives:
  #- Move the CA certificate (`"$ca_private_key_filename"`) into `/usr/local/share/ca-certificates/ca.crt`.
  cp "$ca_private_key_filename" "/usr/local/share/ca-certificates/$ca_private_key_filename"

  # TODO: Verify target file exists.

  # TODO: Verify target file MD5sum.

  # Update the Cert Store with:
  sudo update-ca-certificates
}

# On Android
# The exact steps vary device-to-device, but here is a generalised guide:
# 1. Open Phone Settings
# 2. Locate `Encryption and Credentials` section. It is generally found under `Settings > Security > Encryption and Credentials`
# 3. Choose `Install a certificate`
# 4. Choose `CA Certificate`
# 5. Locate the certificate file `"$ca_private_key_filename"` on your SD Card/Internal Storage using the file manager.
# 6. Select to load it.
# 7. Done!
