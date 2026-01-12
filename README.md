# SideStore-WireGuard

⚠️ **DO NOT USE THIS if LocalDevVPN / StosVPN works for you.**

## What is it? （中国大陆用户请直接往下看）

**This is a WireGuard-based workaround for SideStore Issue \#1143.**

It is **only** required in Mainland China. (Completely unnecessary elsewhere. You can safely close this page if you are not located in Mainland China.)

It does **not** replace LocalDevVPN or StosVPN. It only exists for environments where those solutions do not work.

This setup routes traffic to `10.7.0.1/32` into a dedicated WireGuard server and folds it back to the iOS device itself, satisfying SideStore’s VPN check without running a full VPN gateway.

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

如果你对细节感兴趣，请参阅上述教程。简要来说，我们通过 IP 地址判定分流，将发往 10.7.0.1/32 的数据包包装了一下发回给了你的 iOS 设备。

## 如何使用

在开始之前，请确保你的客户端环境支持同时使用
**日常的互联网访问工具**与 WireGuard 隧道，这很重要。

1. 用你最喜欢的 Docker 工作流构建这个镜像，然后把两份 config 按照标准的 WireGuard 方式配置正确后，按照 linuxserver/wireguard 中描述的方式启动你的容器。
2. 在**你平时使用的互联网访问工具**中配置一条 IP-CIDR 规则将 10.7.0.1/32 的流量通过专用的 WireGuard 服务端。
3. 前往 SideStore 续签。
