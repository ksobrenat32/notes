# Cerbot

Let's encrypt, easy way to get certificate

    sudo apt install certbot

## DNS certonly

Get a certificate modifying a TXT on the dns, you can use wildcards like `*.domain.tld`. You do not need a web service running

    sudo certbot --manual --preferred-challenges dns certonly

## Nginx

Get a certificate while using nginx, difficult to use wildcards and sometimes tricky.

Install the pluggin with 

    sudo apt-get install python3-certbot-nginx

Generate a certificate

    sudo certbot --nginx -d sub.domain.tld