#!/bin/bash
set -e

# متغیرها
WG_PASSWORD=${WG_PASSWORD:-Mardook2025!}
SS_PASSWORD=${SS_PASSWORD:-Shadow1403@}
SS_METHOD=${SS_METHOD:-2022-blake3-aes-128-gcm}
UUID=${UUID:-$(cat /proc/sys/kernel/random/uuid)}

# ساخت کلیدهای WireGuard
wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey
WG_PRIVATE_KEY=$(cat /etc/wireguard/privatekey)
WG_PUBLIC_KEY=$(cat /etc/wireguard/publickey)

# ساخت کانفیگ WireGuard
envsubst < /etc/wireguard/wg0.conf.template > /etc/wireguard/wg0.conf

# ساخت کانفیگ Shadowsocks 2022
cat > /etc/shadowsocks-libev/config.json <<EOF
{
    "server":"0.0.0.0",
    "server_port":8388,
    "password":"$SS_PASSWORD",
    "method":"$SS_METHOD",
    "plugin":"v2ray-plugin",
    "plugin_opts":"server;mode=quic"
}
EOF

# ساخت صفحه وب ساده + QR کد + کانفیگ‌ها
cat > /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html><head><title>VPN Ready</title><meta charset="utf-8">
<style>body{font-family:sans-serif;background:#000;color:#0f0;text-align:center;padding:50px;}</style>
</head><body>
<h1>WireGuard + Shadowsocks 2022</h1>
<p>WireGuard Config: <a href="/wg-config">/wg-config</a></p>
<p>Shadowsocks QR: <img src="/ss-qr" width="300"></p>
<p>Shadowsocks Link: <a href="/ss">/ss</a></p>
</body></html>
EOF

# صفحه کانفیگ WireGuard
cat > /usr/share/nginx/html/wg-config <<EOF
[Interface]
PrivateKey = client_private_key_will_be_replaced
Address = 10.0.0.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = $WG_PUBLIC_KEY
AllowedIPs = 0.0.0.0/0
Endpoint = $(curl -s ifconfig.me):8888
PersistentKeepalive = 25
EOF

# صفحه QR و لینک Shadowsocks
cat > /usr/share/nginx/html/ss <<EOF
ss://$(echo -n "$SS_METHOD:$SS_PASSWORD@$(curl -s ifconfig.me):8388" | base64 -w0)?plugin=v2ray-plugin%3Bmode%3Dquic
EOF

qrencode -o /usr/share/nginx/html/ss-qr.png "ss://$(echo -n "$SS_METHOD:$SS_PASSWORD@$(curl -s ifconfig.me):8388" | base64 -w0)?plugin=v2ray-plugin%3Bmode%3Dquic"
echo "<img src='/ss-qr.png'>" > /usr/share/nginx/html/ss-qr

# اجرای سرویس‌ها
ss-server -c /etc/shadowsocks-libev/config.json -u &
wg-quick up wg0 &
nginx -g 'daemon off;'
