# Cerbot

Let's encrypt, easy way to get certificate

```bash
sudo apt install certbot
```

## DNS certonly

Get a certificate modifying a TXT on the dns, you can use
 wildcards like `*.domain.tld`. You do not need a web service running

```bash
sudo certbot --manual --preferred-challenges dns certonly
```

## Nginx

Get a certificate while using nginx, difficult to use wildcards
 and sometimes tricky.

Install the pluggin and get a certificate

```bash
sudo apt-get install python3-certbot-nginx
sudo certbot --nginx -d sub.domain.tld
```

