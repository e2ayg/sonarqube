#!/bin/bash

# Set variables
DOMAIN=""
COUNTRY=""
STATE=""
LOCALITY=""
ORGANIZATION=""
ORGANIZATIONAL_UNIT=""
EMAIL=""
DAYS_VALID=365
REGION="us-west-2"
CERT_DIR="$HOME/self-signed-acm"

# Create a directory for the certificate files
mkdir -p "$CERT_DIR"
cd "$CERT_DIR" || exit

# Generate a private key
openssl genrsa -out private.key 2048
if [ $? -ne 0 ]; then
  echo "Failed to generate private key."
  exit 1
fi

# Generate a Certificate Signing Request (CSR)
openssl req -new -key private.key -out csr.pem -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/CN=$DOMAIN/emailAddress=$EMAIL"
if [ $? -ne 0 ]; then
  echo "Failed to generate CSR."
  exit 1
fi

# Generate the self-signed certificate
openssl x509 -req -days $DAYS_VALID -in csr.pem -signkey private.key -out certificate.crt
if [ $? -ne 0 ]; then
  echo "Failed to generate self-signed certificate."
  exit 1
fi

# Convert the private key to PEM format
openssl rsa -in private.key -outform PEM -out private.key.pem
if [ $? -ne 0 ]; then
  echo "Failed to convert private key to PEM format."
  exit 1
fi

# Convert the certificate to PEM format
openssl x509 -in certificate.crt -outform PEM -out certificate.crt.pem
if [ $? -ne 0 ]; then
  echo "Failed to convert certificate to PEM format."
  exit 1
fi

# Import the certificate to ACM
ARN=$(aws acm import-certificate \
    --certificate file://"$CERT_DIR"/certificate.crt.pem \
    --private-key file://"$CERT_DIR"/private.key.pem \
    --region "$REGION" \
    --output text \
    --query 'CertificateArn')

if [ $? -eq 0 ]; then
    echo "Certificate successfully imported to ACM."
    echo "ARN: $ARN"
else
    echo "Failed to import certificate to ACM."
    exit 1
fi

# Clean up (optional - remove this if you want to keep the files)
rm private.key csr.pem certificate.crt private.key.pem certificate.crt.pem

echo "Certificate files cleaned up."
