# AstraFlow Skills

个人可复用的 AstraFlow Skills 专区。每个 Skill 放在 `skills/<skill-slug>/`，保留其 `SKILL.md` 和所需的 `scripts/`、`references/` 等资源。

## Skill 目录

### [Astra Muse](skills/astra-muse/)
创建并启动 UCloud Agent Sandbox 图形桌面、验证 noVNC 与出口 IP，并在 Chrome 打开指定网站。默认使用 `us-ca`、desktop 8C8G、8 小时过期；默认不截图、不代登录。

## 安装

在 AstraFlow Skills 页面从此 GitHub 仓库安装，并选择 `skills/astra-muse`。也可以使用 AstraFlow 的 `install_astraflow_skill` 工具，仓库地址为 `https://github.com/lious68/astra-skills`，Skill 路径为 `skills/astra-muse`。

## 用法

> 使用 astra-muse，在 UCloud Sandbox 打开 `https://example.com`。创建后自动启动桌面、验证 noVNC 和美国出口 IP，并在右侧打开桌面；不要截图或登录。
