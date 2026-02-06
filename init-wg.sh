#!/bin/sh
set -e

[ -f .env ] && . ./.env

: "${WG_PORT:?WG_PORT must be set in .env}"
PORT="$WG_PORT"

CLIENT_CONF="/work/client.conf"

usage() {
  echo "Usage:"
  echo "  $0 [SERVER_IP]         Initial setup (generate keys + configs)"
  echo "  $0 qr                  Show QR code from existing client.conf"
  echo "  $0 update-ip SERVER_IP Update server IP in client.conf"
  echo "  $0 sync-routes          Sync AllowedIPs from template to client.conf"
  exit 1
}

show_qr() {
  if [ ! -f "$CLIENT_CONF" ]; then
    echo "ERROR: $CLIENT_CONF not found. Run initial setup first." >&2
    exit 1
  fi
  echo "Scan the QR code below with WireGuard app:"
  echo ""
  qrencode -t ansiutf8 < "$CLIENT_CONF"
}

cmd_update_ip() {
  NEW_IP="$1"
  if [ -z "$NEW_IP" ]; then
    echo "ERROR: SERVER_IP is required for update-ip." >&2
    usage
  fi
  if [ ! -f "$CLIENT_CONF" ]; then
    echo "ERROR: $CLIENT_CONF not found. Run initial setup first." >&2
    exit 1
  fi
  sed -i "s|^Endpoint = .*|Endpoint = ${NEW_IP}:${PORT}|" "$CLIENT_CONF"
  echo "Endpoint updated to ${NEW_IP}:${PORT}"
  echo ""
  show_qr
}

cmd_sync_routes() {
  if [ ! -f "$CLIENT_CONF" ]; then
    echo "ERROR: $CLIENT_CONF not found. Run initial setup first." >&2
    exit 1
  fi
  ALLOWED=$(grep '^AllowedIPs' /work/client.example.conf | sed 's/^AllowedIPs = //')
  sed -i "s|^AllowedIPs = .*|AllowedIPs = ${ALLOWED}|" "$CLIENT_CONF"
  echo "AllowedIPs updated to: ${ALLOWED}"
  echo ""
  show_qr
}

cmd_init() {
  SERVER_IP="$1"
  if [ -z "$SERVER_IP" ]; then
    echo "WARNING: SERVER_IP not provided." >&2
    echo "         You must manually edit client.conf and set Endpoint." >&2
    SERVER_IP="<ServerIp>"
  fi

  mkdir -p /config/wg_confs

  if [ -f /config/wg_confs/server.conf ]; then
    echo "server.conf already exists, aborting."
    exit 1
  fi

  SERVER_PRIV=$(wg genkey)
  SERVER_PUB=$(echo "$SERVER_PRIV" | wg pubkey)

  CLIENT_PRIV=$(wg genkey)
  CLIENT_PUB=$(echo "$CLIENT_PRIV" | wg pubkey)

  sed \
    -e "s|<PrivateKey>|$CLIENT_PRIV|g" \
    -e "s|<PublicKey>|$SERVER_PUB|g" \
    -e "s|<ServerIp>|$SERVER_IP|g" \
    -e "s|<Port>|$PORT|g" \
    /work/client.example.conf > "$CLIENT_CONF"

  sed \
    -e "s|<PrivateKey>|$SERVER_PRIV|g" \
    -e "s|<PublicKey>|$CLIENT_PUB|g" \
    -e "s|<Port>|$PORT|g" \
    /work/server.example.conf > /config/wg_confs/server.conf

  echo "WireGuard configs generated."
  echo ""
  show_qr
}

case "${1:-}" in
  qr)
    show_qr
    ;;
  update-ip)
    shift
    cmd_update_ip "$1"
    ;;
  sync-routes)
    cmd_sync_routes
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    cmd_init "$1"
    ;;
esac
