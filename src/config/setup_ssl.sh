#!/usr/bin/env bash

generate_ca_cert() {
  # Generate RSA
  openssl genrsa -aes256 -out ca-key.pem 4096

  # Generate a public CA Cert
  openssl req -new -x509 -sha256 -days 365 -key ca-key.pem -out ca.pem
}

generate_ssl_certificate() {
  # Create a RSA key
  openssl genrsa -out cert-key.pem 4096

  # Create a Certificate Signing Request (CSR)
  openssl req -new -sha256 -subj "/CN=yourcn" -key cert-key.pem -out cert.csr
  # Create a `extfile` with all the alternative names
  echo "subjectAltName=DNS:your-dns.record,IP:257.10.10.1" >>extfile.cnf

  # optional
  #echo extendedKeyUsage = serverAuth >> extfile.cnf

  # Create the certificate
  openssl x509 -req -sha256 -days 365 -in cert.csr -CA ca.pem -CAkey ca-key.pem -out cert.pem -extfile extfile.cnf -CAcreateserial
}

verify_certificates() {
  openssl verify -CAfile ca.pem -verbose cert.pem
}

install_the_ca_cert_as_a_trusted_root_ca() {
  # On Debian & Derivatives:
  #- Move the CA certificate (`ca.pem`) into `/usr/local/share/ca-certificates/ca.crt`.

  # Update the Cert Store with:
  sudo update-ca-certificates
}

# On Android
# The exact steps vary device-to-device, but here is a generalised guide:
# 1. Open Phone Settings
# 2. Locate `Encryption and Credentials` section. It is generally found under `Settings > Security > Encryption and Credentials`
# 3. Choose `Install a certificate`
# 4. Choose `CA Certificate`
# 5. Locate the certificate file `ca.pem` on your SD Card/Internal Storage using the file manager.
# 6. Select to load it.
# 7. Done!
