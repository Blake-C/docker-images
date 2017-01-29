FROM nginx:1.10.2-alpine
MAINTAINER Blake Cerecero <blake@digitalblake.com>

COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www/public_html

RUN rm -rf /var/www/html