#!/bin/bash

# === CONFIGURATION ===
DOMAIN="internal.example.com"
PUBLIC_DNS="8.8.8.8"

echo "🔍 Checking resolution for: $DOMAIN"

# Resolve using system DNS
IP_SYSTEM=$(dig +short "$DOMAIN" | tail -n1)
echo "System DNS resolved $DOMAIN to: $IP_SYSTEM"

# Resolve using Google DNS
IP_PUBLIC=$(dig @$PUBLIC_DNS +short "$DOMAIN" | tail -n1)
echo "Public DNS ($PUBLIC_DNS) resolved $DOMAIN to: $IP_PUBLIC"

# Handle failure
if [[ -z "$IP_SYSTEM" ]]; then
    echo "❌ System DNS cannot resolve $DOMAIN."
fi
if [[ -z "$IP_PUBLIC" ]]; then
    echo "❌ Public DNS cannot resolve $DOMAIN."
fi

echo "----------------------------------------"

# If resolution succeeded, test connectivity
if [[ -n "$IP_SYSTEM" ]]; then
    echo "🌐 Testing connectivity to $IP_SYSTEM"

    # Ping test
    ping -c 3 "$IP_SYSTEM"

    # Test Port 80
    echo "Testing Port 80..."
    timeout 3 bash -c "echo > /dev/tcp/$IP_SYSTEM/80" && echo "✅ Port 80 is open" || echo "❌ Port 80 is closed"

    # Test Port 443
    echo "Testing Port 443..."
    timeout 3 bash -c "echo > /dev/tcp/$IP_SYSTEM/443" && echo "✅ Port 443 is open" || echo "❌ Port 443 is closed"

    echo "----------------------------------------"

    # Nmap scan (optional but useful)
    echo "🧪 Running basic port scan:"
    nmap -p 80,443 "$IP_SYSTEM"

else
    echo "⚠️ Skipping connectivity tests because DNS resolution failed."
fi

echo "----------------------------------------"

# Suggest /etc/hosts workaround
if [[ -z "$IP_SYSTEM" && -n "$IP_PUBLIC" ]]; then
    echo "💡 Suggestion:"
    echo "You can temporarily bypass DNS by adding this to your /etc/hosts:"
    echo "$IP_PUBLIC $DOMAIN"
fi

echo "----------------------------------------"

# Check if system uses systemd-resolved
if systemctl is-active --quiet systemd-resolved; then
    echo "🔧 systemd-resolved is active."
    echo "You can set persistent DNS servers in /etc/systemd/resolved.conf"
else
    echo "ℹ️ Systemd-resolved is not active. Check /etc/resolv.conf or NetworkManager."
fi

echo "✅ Done!"

