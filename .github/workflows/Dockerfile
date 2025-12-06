FROM alpine:edge

# فعال کردن ریپازیتوری edge برای پکیج‌های Shadowsocks و V2Ray
RUN echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories

RUN apk update && \
    apk add --no-cache \
    wireguard-tools@edge \
    openresolv \
    iptables \
    shadowsocks-libev@edge \
    v2ray@edge \
    nginx \
    curl \
    bash

# کپی فایل‌ها
COPY entrypoint.sh /entrypoint.sh
COPY wg0.conf.template /etc/wireguard/wg0.conf.template
COPY ss-config.json /etc/shadowsocks-libev/config.json
COPY nginx.conf /etc/nginx/nginx.conf

RUN chmod +x /entrypoint.sh

EXPOSE 80 8388 8888/udp

ENTRYPOINT ["/entrypoint.sh"]
