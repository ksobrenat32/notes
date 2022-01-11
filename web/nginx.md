# Configuring nginx

## Basic - nginx.conf

Without conf.d/ and sites-enabled/ for simplicity. With a proxy pass

```nginx
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 768;
}

http {
    sendfile on;
    tcp_nopush on;
    types_hash_max_size 2048;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
    ssl_prefer_server_ciphers on;
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    gzip on;

    # Default
    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name _;
        # Do not return anything by default
        return 444;
    }

    # Service Example
    server {
        server_name <domain.tld>;
        location / {
            # Change this port for proxy pass
            proxy_pass http://127.0.0.1:8080;
        }

        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        # You can get a certificate with certbot
        ssl_certificate /etc/letsencrypt/live/<domain.tld>/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/<domain.tld>/privkey.pem;
    }
}
```

## More body size

For cases when you need to send more data through nginx.

```nginx
server {
    server_name bigfiles.domain.tld;
    client_max_body_size 512M;
    ...
}
```

## IPv6 only

If you only want it on IPv6

```nginx
server {
    listen [::]:80 default_server ipv6only=on;
    server_name _;
    ...
}
```

## SELINUX

For proxy pass with selinux use:

```bash
setsebool -P httpd_can_network_connect on 
```

Problems with files permissions, solve them with

```bash
sudo grep nginx /var/log/audit/audit.log | audit2allow -M nginx > nginx.te \ 
&& sudo semodule -i nginx.pp
```

## File server

If you want to serve files

```nginx
server {
    ...
    root /directorie/to/serve;
    autoindex on;
    autoindex_exact_size off;
    autoindex_localtime on;
}
```

## Authentication

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
