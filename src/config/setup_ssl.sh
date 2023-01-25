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
CA_PRIVATE_KEY_FILENAME="ca-key.pem"
CA_PUBLIC_KEY_FILENAME="ca.pem"
# Same file as ca.pem except different file extension and content.
CA_PUBLIC_CERT_FILENAME="ca.crt"

# Then you create a SSL certificate.
SSL_PRIVATE_KEY_FILENAME="cert-key.pem"

# Then create a sign-request (for your own CA to sign your own SSL certificate)
CA_SIGN_SSL_CERT_REQUEST_FILENAME="cert.csr"
SIGNED_DOMAINS_FILENAME="extfile.cnf"

# Then create the signed public SSL cert.
SSL_PUBLIC_KEY_FILENAME="cert.pem"

# Then merge the CA and SLL cert into one.
MERGED_CA_SSL_CERT_FILENAME="fullchain.pem"

setup_tor_ssl() {
  local onion_address="$1"

  # TODO: if files already exist, perform double check on whether user wants to
  # overwrite the files.

  # Create domains accepted by certificate.
  local domains
  domains="DNS:localhost,DNS:$onion_address"
  echo "domains=$domains.end_without_space"

  delete_target_files

  # Generate and apply certificate.
  generate_ca_cert "$CA_PRIVATE_KEY_FILENAME" "$CA_PUBLIC_KEY_FILENAME"

  generate_ssl_certificate "$CA_PUBLIC_KEY_FILENAME" "$CA_PRIVATE_KEY_FILENAME" "$CA_SIGN_SSL_CERT_REQUEST_FILENAME" "$SIGNED_DOMAINS_FILENAME" "$SSL_PUBLIC_KEY_FILENAME" "$SSL_PRIVATE_KEY_FILENAME" "$domains"

  verify_certificates "$CA_PUBLIC_KEY_FILENAME" "$SSL_PUBLIC_KEY_FILENAME"

  merge_ca_and_ssl_certs "$SSL_PUBLIC_KEY_FILENAME" "$CA_PUBLIC_KEY_FILENAME" "$MERGED_CA_SSL_CERT_FILENAME"

  install_the_ca_cert_as_a_trusted_root_ca "$CA_PUBLIC_KEY_FILENAME" "$CA_PUBLIC_CERT_FILENAME"

  add_certs_to_nextcloud "$SSL_PUBLIC_KEY_FILENAME" "$SSL_PRIVATE_KEY_FILENAME" "$MERGED_CA_SSL_CERT_FILENAME"

  copy_file "$CA_PUBLIC_KEY_FILENAME" "$ROOT_CA_PEM_PATH" "true"

  make_self_signed_root_cert_trusted_on_ubuntu
  #make_self_signed_root_cert_trusted_on_ubuntu_retry
}

generate_ca_cert() {
  local ca_private_key_filename="$1"
  local ca_public_key_filename="$2"

  # TODO: make the user specify this in CLI!
  echo "some_ssl_password" >"ssl_password.txt"

  # Generate RSA
  #openssl genrsa -aes256 -out "$ca_private_key_filename" 4096
  openssl genrsa -passout file:ssl_password.txt -aes256 -out "$ca_private_key_filename" 4096

  # Generate a public CA Cert
  # openssl req -new -x509 -sha256 -days 365 -key "$ca_private_key_filename" -out "$ca_public_key_filename"
  # Add passsword to cli.
  #openssl req -passin file:ssl_password.txt -new -x509 -sha256 -days 365 -key "$ca_private_key_filename" -out "$ca_public_key_filename"
  # Automatically specify Country Name.
  # TODO: make the user specify this in CLI!
  openssl req -passin file:ssl_password.txt -subj "/C=FR/" -new -x509 -sha256 -days 365 -key "$ca_private_key_filename" -out "$ca_public_key_filename"
}

generate_ssl_certificate() {
  local ca_public_key_filename="$1"
  local ca_private_key_filename="$2"
  local ca_sign_ssl_cert_request_filename="$3"
  local signed_domains_filename="$4"
  local ssl_public_key_filename="$5"
  local ssl_private_key_filename="$6"
  local domains="$7"
  # Example supported domains:
  # DNS:your-dns.record,IP:257.10.10.1

  # Create a RSA key
  openssl genrsa -out "$ssl_private_key_filename" 4096

  # Create a Certificate Signing Request (CSR)
  openssl req -new -sha256 -subj "/CN=yourcn" -key "$ssl_private_key_filename" -out "$ca_sign_ssl_cert_request_filename"

  # Create a `extfile` with all the alternative names
  echo "subjectAltName=$domains" >>"$signed_domains_filename"

  # optional
  #echo extendedKeyUsage = serverAuth >> "$ca_sign_ssl_cert_request_filename"

  # Create the public SSL certificate.
  #openssl x509 -req -sha256 -days 365 -in "$ca_sign_ssl_cert_request_filename" -CA "$ca_public_key_filename" -CAkey "$ca_private_key_filename" -out "$ssl_public_key_filename" -extfile "$signed_domains_filename" -CAcreateserial
  # TODO: make the user specify this in CLI!
  openssl x509 -passin file:ssl_password.txt -req -sha256 -days 365 -in "$ca_sign_ssl_cert_request_filename" -CA "$ca_public_key_filename" -CAkey "$ca_private_key_filename" -out "$ssl_public_key_filename" -extfile "$signed_domains_filename" -CAcreateserial

}

verify_certificates() {
  local ca_public_key_filename="$1"
  local ssl_public_key_filename="$2"
  openssl verify -CAfile "$ca_public_key_filename" -verbose "$ssl_public_key_filename"
}

merge_ca_and_ssl_certs() {
  local ssl_public_key_filename="$1"
  local ca_public_key_filename="$2"
  local merged_ca_ssl_cert_filename="$3"

  cat "$ssl_public_key_filename" >"$merged_ca_ssl_cert_filename"
  cat "$ca_public_key_filename" >>"$merged_ca_ssl_cert_filename"
}

install_the_ca_cert_as_a_trusted_root_ca() {
  local ca_public_key_filename="$1"
  local ca_public_cert_filename="$2"

  # The file in the ca-certificates dir must be of extension .crt:
  openssl x509 -outform der -in "$ca_public_key_filename" -out "$ca_public_cert_filename"

  # First remove any old cert if it existed.
  sudo rm -f "/usr/local/share/ca-certificates/$ca_public_cert_filename"
  sudo update-ca-certificates

  # TODO: Verify target directory exists.
  # On Debian & Derivatives:
  #- Move the CA certificate (`"$ca_private_key_filename"`) into `/usr/local/share/ca-certificates/ca.crt`.
  sudo cp "$ca_public_cert_filename" "/usr/local/share/ca-certificates/$ca_public_cert_filename"

  # TODO: Verify target file exists.

  # TODO: Verify target file MD5sum.

  # Update the Cert Store with:
  sudo update-ca-certificates
}

add_certs_to_nextcloud() {
  local ssl_public_key_filename="$1"
  local ssl_private_key_filename="$2"
  local merged_ca_ssl_cert_filename="$3"

  # First copy the files into nextcloud.
  # Source: https://github.com/nextcloud-snap/nextcloud-snap/issues/256
  # (see nextcloud.enable-https custom -h command).
  #sudo cp ca.pem /var/snap/nextcloud/current/ca.pem
  sudo cp "$ssl_public_key_filename" /var/snap/nextcloud/current/"$ssl_public_key_filename"
  sudo cp "$ssl_private_key_filename" /var/snap/nextcloud/current/"$ssl_private_key_filename"
  sudo cp "$merged_ca_ssl_cert_filename" /var/snap/nextcloud/current/"$merged_ca_ssl_cert_filename"

  # CLI sudo /snap/bin/nextcloud.enable-https custom Says:
  sudo /snap/bin/nextcloud.enable-https custom "/var/snap/nextcloud/current/$ssl_public_key_filename" "/var/snap/nextcloud/current/$ssl_private_key_filename" "/var/snap/nextcloud/current/$merged_ca_ssl_cert_filename"
}

delete_target_files() {
  rm -f "$CA_PRIVATE_KEY_FILENAME"
  rm -f "$CA_PUBLIC_CERT_FILENAME"
  rm -f "$CA_PUBLIC_KEY_FILENAME"
  rm -f "$SSL_PRIVATE_KEY_FILENAME"
  rm -f "$CA_SIGN_SSL_CERT_REQUEST_FILENAME"
  rm -f "$SIGNED_DOMAINS_FILENAME"
  rm -f "$SSL_PUBLIC_KEY_FILENAME"
  rm -f "$MERGED_CA_SSL_CERT_FILENAME"
  rm -f "$ROOT_CA_PEM_PATH"
  sudo rm -f "/usr/local/share/ca-certificates/$CA_PUBLIC_KEY_FILENAME"
  sudo rm -f "/usr/local/share/ca-certificates/$CA_PUBLIC_CERT_FILENAME"
  sudo rm -f "/var/snap/nextcloud/current/$SSL_PUBLIC_KEY_FILENAME"
  sudo rm -f "/var/snap/nextcloud/current/$SSL_PRIVATE_KEY_FILENAME"
  sudo rm -f "/var/snap/nextcloud/current/$MERGED_CA_SSL_CERT_FILENAME"

}

# On Android (This has been automated)
# 1. Open Phone Settings
# The exact steps vary device-to-device, but here is a generalised guide:
# 2. Locate `Encryption and Credentials` section. It is generally found under `Settings > Security > Encryption and Credentials`
# 3. Choose `Install a certificate`
# 4. Choose `CA Certificate`
# 5. Locate the certificate file `"$ca_private_key_filename"` on your SD Card/Internal Storage using the file manager.
# 6. Select to load it.
# 7. Done!

make_self_signed_root_cert_trusted_on_ubuntu() {
  # source: https://ubuntu.com/server/docs/security-trust-store
  # source: https://askubuntu.com/questions/73287/how-do-i-install-a-root-certificate

  ensure_apt_pkg "ca-certificates"

  # TODO: add to remove in uninstallation.
  sudo mkdir -p /usr/local/share/ca-certificates/nextcloud_ssl

  sudo cp "$CA_PUBLIC_CERT_FILENAME" "/usr/local/share/ca-certificates/nextcloud_ssl/$CA_PUBLIC_CERT_FILENAME"

  # Add the .crt file's path relative to /usr/local/share/ca-certificates to:
  # /etc/ca-certificates.conf:
  #sudo dpkg-reconfigure ca-certificates

  sudo update-ca-certificates

  # TODO: verify the ca is in the trusted ca-certificates.
  #dir with ca certificates:
  # /etc/ssl/certs

  add_self_signed_root_cert_to_firefox
}

add_self_signed_root_cert_to_firefox() {
  echo "TODO: check if the json file exists."
  echo "TODO: check if the json file already contains the Certificates entry."
  echo "TODO: if not, safely add that entry with parametererised ca.crt name."
  # Use policies in:
  #/usr/lib/firefox/distribution/policies.json
  # {
  #    "policies": {
  #        "Certificates": {
  #            "Install": [
  #                "/usr/local/share/ca-certificates/nextcloud_ssl/ca.crt"
  #            ]
  #        }
  #    }
  #}
  echo "TODO: if json not exists, point user to url where to add ca.crt "
  echo "manually."
}
