#!/usr/bin/with-contenv sh

echo "[sidestore] loading nftables rules"

nft -f /etc/nftables/sidestore.nft || {
  echo "[sidestore] failed to load nft rules"
  exit 1
}

echo "[sidestore] nftables rules loaded"

