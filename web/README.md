# Web server notes

## Nginx

Basic nginx.conf this redirects all http to https
 and uses `conf.d` to configure other servers

```nginx
user  nginx;
worker_processes auto;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}

http {
    sendfile on;
    tcp_nopush on;
    types_hash_max_size 2048;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    gzip on;

    # Security

    # Certbot recommends : 
    ssl_session_cache shared:le_nginx_SSL:10m;
    ssl_session_timeout 1440m;
    ssl_session_tickets off;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;
    ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";

    server_tokens off;
    client_header_buffer_size 1k;
    large_client_header_buffers 2 1k;
    add_header Strict-Transport-Security "max-age=15768000; includeSubDomains" always;
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";

    # Logs
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # Default
    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name _;
        # Redirect to https
        return 301 https://$host$request_uri;
    }

    # Include services
    include /etc/nginx/conf.d/*.conf;

}
```

For running services you need to create a service.conf on
 the conf.d directory, something like this

```nginx
server {
    server_name your.domain;
    
    listen 443 ssl http2;

    ssl_certificate /etc/letsencrypt/live/your.domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your.domain/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_http_version 1.1;
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

}
```

For cases when you need to send more data through nginx.

```nginx
server {
    server_name bigfiles.domain.tld;
    client_max_body_size 512M;
    ...
}
```

If you only want it on IPv6

```nginx
server {
    listen [::]:80 default_server ipv6only=on;
    server_name _;
    ...
}
```

For proxy pass with selinux use:

```bash
setsebool -P httpd_can_network_connect on 
```

Problems with files permissions and selinux , solve them with

```bash
sudo grep nginx /var/log/audit/audit.log | audit2allow -M nginx > nginx.te \ 
&& sudo semodule -i nginx.pp
```

### Serving files

```nginx
server {
    ...
    root /directorie/to/serve;
    autoindex on;
    autoindex_exact_size off;
    autoindex_localtime on;
}
```

### Authentication

To generate a password file

> Only use -c when creating the file

```bash
sudo htpasswd -c /etc/nginx/.htpasswd first_user
```

Add this to your server config

```nginx
server {
    auth_basic "Private sharing files";
    auth_basic_user_file /etc/nginx/.htpasswd; 
}
```

### Common error codes

code | class
--- | ---
1xx | Informational
2xx | Success
3xx | Redirection
4xx | Client Error
5xx | Server Error

`return 400;` - Bad Request: the HTTP request that was sent to the
 server has invalid syntax.

`return 401;` - Unauthorized: that the user trying to access
 the resource has not been authenticated or has not been
 authenticated correctly.

`return 403;` - Forbidden: that the user made a valid request but
 the server is refusing to serve the request, due to a lack of
 permission to access the requested resource

`return 404;` - Not found: that the user is able to communicate
 with the server but it is unable to locate the requested file
 or resource.

`return 444;` - Not return anything

`return 500;` - Internal server error: that server cannot process
 the request for an unknown reason. Sometimes this code will
 appear when more specific 5xx errors are more appropriate.

`return 502;` - Bad Gateway: that the server is a gateway or proxy
 server, and it is not receiving a valid response from the backend
 servers that should actually fulfill the request.

`return 503;` - Gateway timeout: that the server is a gateway or
 proxy server, and it is not receiving a response from the backend
 servers within the allowed time period.

## Certbot

Let's encrypt, has a service so you can easily get ssl certificates,
 the basic cerbot command can be installed with

```bash
sudo dnf install certbot
# If you want to use pluggins like nginx do it with pip
sudo dnf install python3 augeas-libs
sudo python3 -m venv /opt/certbot/
sudo /opt/certbot/bin/pip install --upgrade pip
sudo /opt/certbot/bin/pip install certbot
sudo ln -s /opt/certbot/bin/certbot /usr/bin/certbot
echo "0 0,12 * * * root /usr/bin/certbot renew -q" | sudo tee -a /etc/crontab > /dev/null
```

It is possible to get a certificate modifying a TXT record on the dns,
 the advantage is that you can use wildcards like `*.domain.tld` and
 there is no need to have a web server running or exposed. But you will
 have to renew this certificates manually every 90 days.

```bash
sudo certbot --manual --preferred-challenges dns certonly
```

The automated way is having a webserver exposed so letsencrypt can verify
 you own the domain, the requirements is having nginx up and running and
 public DNS records pointing to that server, but the advantage is that those
 certificates will automatically renew.

```sh
sudo /opt/certbot/bin/pip install certbot-nginx
sudo certbot certonly --nginx -d sub.domain.tld
```

## Using private SSL certificates and Certification Authority

> From [vaultwarden wiki](https://github.com/dani-garcia/vaultwarden/wiki/Private-CA-and-self-signed-certs-that-work-with-Chrome)

In cases you want ssl certificates but not need them to be public,
 you can sign your own ones and only trust them on your devices,
 this way there is no need of external authorities like letsencrypt
 and free use of any domain you want, even if not registrated. In
 the example, `example.lan` is the domain being `example` the name of
 the service

The first step is creating the key of the Certification Authority.

```sh
openssl genpkey -algorithm RSA -aes128 -out private-ca.key -outform PEM -pkeyopt rsa_keygen_bits:2048
```

And for creating the certificate, that will work for 10 years, this
 is the certificate that need to be trusted by the client devices.

```sh
openssl req -x509 -new -nodes -sha256 -days 3650 -key private-ca.key -out self-signed-ca-cert.crt
```

In order to create domain certificates, create a key

```sh
openssl genpkey -algorithm RSA -out service.key -outform PEM -pkeyopt rsa_keygen_bits:2048
```

And create a certificate request

```sh
openssl req -new -key service.key -out service.csr
```

Fill the configuration file `service.ext`, change the dns
 alt_names accordingly.

```ext
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

```sh
openssl x509 -req -in service.csr -CA self-signed-ca-cert.crt -CAkey private-ca.key -CAcreateserial -out service.crt -days 365 -sha256 -extfile service.ext
```

To use this certificates on Nginx copy the service.crt and
 service.key file to the server in a directory it can be
 accessed by the nginx process.
 **CHANGE PERMITIONS TO 400 AND CHOWN TO ROOT**

```nginx
ssl_certificate /etc/nginx/certs/service.crt;
ssl_certificate_key /etc/nginx/certs/vaultwarden.key;
```

Finally, copy the `self-signed-ca-cert.crt` to every device and authorize it.

