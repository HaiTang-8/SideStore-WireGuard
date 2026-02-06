FROM lscr.io/linuxserver/wireguard:latest

RUN \
  apk add --no-cache nftables iproute2 libqrencode-tools

COPY sidestore.nft /etc/nftables/sidestore.nft

COPY entrypoint.d/50-sidestore-nft.sh /etc/cont-init.d/50-sidestore-nft.sh
RUN chmod +x /etc/cont-init.d/50-sidestore-nft.sh
