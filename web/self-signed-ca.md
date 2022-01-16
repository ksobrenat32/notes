# Using private SSL certificates and Certification Authority

From https://github.com/dani-garcia/vaultwarden/wiki/Private-CA-and-self-signed-certs-that-work-with-Chrome

## Create C.A. key and certificate

For creating the key of the Certification Authority.

```
openssl genpkey -algorithm RSA -aes128 -out private-ca.key -outform PEM -pkeyopt rsa_keygen_bits:2048
```

And for creating the certificate, it will work for 10 years.

```
openssl req -x509 -new -nodes -sha256 -days 3650 -key private-ca.key -out self-signed-ca-cert.crt
```

## Create domain certificates

First, create a key

```
openssl genpkey -algorithm RSA -out service.key -outform PEM -pkeyopt rsa_keygen_bits:2048
```

And create a certificate request

```
openssl req -new -key service.key -out service.csr
```

Fill the configuration file `service.ext`

```
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = service.lan
DNS.2 = www.service.lan
```

And finaly generate the certificate signed from the C.A.

```
openssl x509 -req -in service.csr -CA self-signed-ca-cert.crt -CAkey private-ca.key -CAcreateserial -out service.crt -days 365 -sha256 -extfile service.ext
```

## Server Nginx

You only need to copy the service.crt and service.key file
 to the server

```nginx
ssl_certificate /etc/nginx/certs/service.crt;
ssl_certificate_key /etc/nginx/certs/vaultwarden.key;
```

## On clients

Copy the `self-signed-ca-cert.crt` to every device and authorize it.
