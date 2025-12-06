FROM alpine:latest

RUN apk add --no-cache wireguard-tools openresolv iptables shadowsocks-libev nginx curl qrencode bash

# کپی فایل‌ها
COPY entrypoint.sh /entrypoint.sh
COPY wg0.conf.template /etc/wireguard/wg0.conf.template
COPY ss-config.json /etc/shadowsocks-libev/config.json
COPY nginx.conf /etc/nginx/nginx.conf

RUN chmod +x /entrypoint.sh

EXPOSE 80 8888/udp

ENTRYPOINT ["/entrypoint.sh"]
