# SideStore-WireGuard

⚠️ **DO NOT USE THIS if LocalDevVPN / StosVPN works for you.**

## What is it? （中国大陆用户请直接往下看）

**This is a WireGuard-based workaround for SideStore Issue \#1143.**

It is **only** required in Mainland China. (Completely unnecessary elsewhere. You can safely close this page if you are not located in Mainland China.)

It does **not** replace LocalDevVPN or StosVPN. It only exists for environments where those solutions do not work.

This setup routes traffic to `10.7.0.1/32` into a dedicated WireGuard server and folds it back to the iOS device itself, satisfying SideStore's VPN check without running a full VPN gateway.

It also forwards Apple service traffic (`17.0.0.0/8`, including `gas.apple.com`) through the server, enabling anisette verification relay for environments where direct access to Apple services is unreliable.

Single-device only. Not a general-purpose VPN.

## 这是什么？

这是一份对以下教程的实现：

https://lantian.pub/article/modify-computer/sidestore-without-stosvpn-across-lan.lantian/

我们假设了什么：

- 你无法正常的使用 LocalDevVPN/StosVPN 在 SideStore 上进行续签
- 你知道如何**正确访问互联网**，且它需要支持基于目标 IP 的分流规则
- 你有一台具有公网 IP 的、可以使用 UDP 的服务器
- 一份服务端对应一台 iOS 设备

简而言之，你需要让**你平时使用的互联网访问工具**把一切发往 10.7.0.1/32 的数据包转发到我们这份专用的 WireGuard 服务端。

本方案**不会**转发其它内网或互联网流量，仅用于满足 SideStore 的 VPN 检查。

此外，本方案还会将 Apple 服务流量（`17.0.0.0/8`，包含 `gas.apple.com`）通过服务端中转，用于解决大陆环境下 anisette 验证不稳定的问题。隧道激活期间，所有 Apple 服务（iCloud、App Store 等）的流量都会经由服务端转发。

如果你对细节感兴趣，请参阅上述教程。简要来说，我们通过 IP 地址判定分流，将发往 10.7.0.1/32 的数据包包装了一下发回给了你的 iOS 设备。

## 如何使用

在开始之前，请确保你的客户端环境支持同时使用
**日常的互联网访问工具**与 WireGuard 隧道，这很重要。

```bash
# 1. Clone 项目
git clone https://github.com/lj2000lj/SideStore-WireGuard.git
cd SideStore-WireGuard

# 2. 生成配置文件
# 你可以在这个时候修改 .env 中记载的端口号
# 该步骤将会生成以下文件：
#   - client.conf # WireGuard 客户端使用
#   - config/wg_confs/server.conf # WireGuard 服务端使用
# 若未提供公网 IP，需要手动修改 client.conf 中的 Endpoint。
docker compose run --rm sidestore-wireguard ./init-wg.sh
# 可选：传入服务器公网 IP 以自动填写 client.conf 中的 Endpoint
# 示例：
# docker compose run --rm sidestore-wireguard ./init-wg.sh 1.2.3.4

# 重新显示客户端配置的 QR 码（如需再次扫描）：
# docker compose run --rm sidestore-wireguard ./init-wg.sh qr

# 服务器 IP 变更后更新客户端配置：
# docker compose run --rm sidestore-wireguard ./init-wg.sh update-ip 5.6.7.8

# 3. 启动 WireGuard 服务端
docker compose up -d

# 4. 在**你平时使用的互联网访问工具**中配置一条 IP-CIDR 规则:
#     10.7.0.1/32  →  WireGuard 服务端

# 5. 前往 SideStore 续签。

```
