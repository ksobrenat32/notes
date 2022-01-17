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

## Services

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
