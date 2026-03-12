# OpenClaw 渠道配置指南

本文档详细说明如何配置各种消息渠道，包括飞书、iMessage、Telegram、WhatsApp、Discord 等。

---

## 目录

1. [飞书机器人](#飞书机器人)
2. [iMessage](#imessage)
3. [Telegram](#telegram)
4. [WhatsApp](#whatsapp)
5. [Discord](#discord)
6. [常见问题](#常见问题)

---

## 飞书机器人

### 环境要求

- **推荐系统**: macOS / Linux / Windows (WSL2)
- **飞书版本**: 企业版或个人版

### 配置步骤

#### 第一步：创建飞书应用

1. 访问 [飞书开放平台](https://open.feishu.cn/app)
2. 使用飞书账号登录
3. 点击 **创建企业自建应用**
4. 填写应用名称（如 "OpenClaw AI助手"）和描述
5. 上传应用图标（可选）

#### 第二步：获取应用凭证

1. 进入应用 → **凭证与基础信息**
2. 复制 **App ID**（格式：`cli_xxx`）
3. 点击显示 **App Secret** 并复制

> ⚠️ **注意**: App Secret 只显示一次，请妥善保存！

#### 第三步：配置应用权限

1. 进入应用 → **权限管理**
2. 点击 **批量导入**，粘贴以下 JSON：

```json
{
  "scopes": {
    "tenant": [
      "im:message",
      "im:chat",
      "im:message:send_as_bot",
      "im:message.p2p_msg:readonly",
      "im:message.group_msg",
      "im:chat.members:bot_access",
      "im:chat.access_event.bot_p2p_chat:read",
      "im:resource",
      "cardkit:card:write"
    ],
    "user": [
      "im:message",
      "im:chat.access_event.bot_p2p_chat:read"
    ]
  }
}
```

3. 点击 **批量导入**
4. 逐个确认添加所有权限

#### 第四步：启用机器人能力

1. 进入应用 → **应用能力** → **机器人**
2. 点击 **开启机器人能力**
3. 设置机器人名称

#### 第五步：配置事件订阅

1. 进入应用 → **事件与回调**
2. 如果看到"需配置服务器"提示，先跳过
3. 点击 **添加事件**
4. 搜索 `im.message.receive_v1`（接收消息）
5. 点击 **添加**
6. 在 **请求地址** 中输入（先不填，后面会让网关自动配置）:
   - 本地: `http://127.0.0.1:18789/feishu/events`
   - 远程: 需要公网地址

#### 第六步：发布应用

1. 进入应用 → **版本管理与发布**
2. 点击 **创建版本**
3. 填写版本号（如 1.0.0）和更新说明
4. 提交发布
5. 点击 **申请发布**（企业自建应用通常自动通过）

#### 第七步：在 OpenClaw 中配置

运行以下命令：

```bash
openclaw channels add
```

按提示选择 **Feishu**，然后输入：
- App ID
- App Secret

或者手动编辑配置文件 `~/.openclaw/openclaw.json`：

```json
{
  "channels": {
    "feishu": {
      "enabled": true,
      "dmPolicy": "pairing",
      "accounts": {
        "main": {
          "appId": "cli_xxxxxx",
          "appSecret": "你的AppSecret"
        }
      }
    }
  }
}
```

#### 第八步：启动网关并完成飞书配置

1. 启动网关：
```bash
openclaw gateway --port 18789
```

2. 回到飞书开放平台 → **事件与回调**
3. 在请求地址输入：`http://127.0.0.1:18789/feishu/events`
4. 点击保存

### 飞书使用技巧

#### 私聊配对

首次使用需要配对：
1. 在飞书中给机器人发送消息
2. 机器人会回复配对码
3. 运行批准：
```bash
openclaw pairing approve feishu <配对码>
```

#### 群组使用

1. 将机器人添加到群聊
2. @机器人 发送消息（默认需要 @提及）
3. 如需无需 @即可回复，编辑配置：
```json
{
  "channels": {
    "feishu": {
      "groups": {
        "群组ID": {
          "requireMention": false
        }
      }
    }
  }
}
```

---

## iMessage

### 环境要求

- **推荐系统**: macOS（需要 macOS 12+）
- **其他方案**: BlueBubbles（支持远程）

### 方案一：本地 iMessage（仅 macOS）

#### 方式 A：使用 BlueBubbles（推荐）

1. **安装 BlueBubbles**：
   - 下载: https://bluebubbles.app
   - 安装并启动

2. **配置 BlueBubbles**：
   - 设置服务器地址和密码
   - 启用 iMessage 同步

3. **在 OpenClaw 中配置**：
```bash
openclaw channels add
```
选择 **BlueBubbles**，输入服务器地址和密码

#### 方式 B：使用本地 imsg（需要 macOS）

1. **安装 imsg**：
```bash
brew install imsg
```

2. **配置 OpenClaw**：
```bash
openclaw channels add
```
选择 **iMessage**

3. **配置示例**：
```json
{
  "channels": {
    "imessage": {
      "enabled": true,
      "cliPath": "/usr/local/bin/imsg"
    }
  }
}
```

### 方案二：远程 iMessage（任何系统）

使用 BlueBubbles 服务器：

```json
{
  "channels": {
    "bluebubbles": {
      "enabled": true,
      "serverUrl": "https://your-server.com",
      "password": "your-password",
      "webhookPath": "/webhook"
    }
  }
}
```

---

## Telegram

### 配置步骤

1. **创建机器人**：
   - 打开 Telegram
   - 搜索 @BotFather
   - 发送 `/newbot` 创建新机器人
   - 获取 Bot Token

2. **配置 OpenClaw**：

```bash
openclaw channels add
```

选择 **Telegram**，输入 Bot Token

或手动配置：

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "你的BotToken"
    }
  }
}
```

3. **启动网关**：
```bash
openclaw gateway --port 18789
```

4. **配对**（首次使用）：
   - 给机器人发送消息
   - 批准配对：
   ```bash
   openclaw pairing approve telegram <配对码>
   ```

---

## WhatsApp

### 配置步骤

1. **登录 WhatsApp**：
```bash
openclaw channels login
```

2. **扫描 QR 码**：
   - 在手机 WhatsApp 中：设置 → 已关联的设备
   - 扫描屏幕上的 QR 码

3. **启动网关**：
```bash
openclaw gateway --port 18789
```

---

## Discord

### 配置步骤

1. **创建 Discord 应用**：
   - 访问 https://discord.com/developers/applications
   - 创建新应用
   - 进入 → Bot → 创建 Bot
   - 复制 Bot Token

2. **添加权限**：
   - 在 Bot 设置中启用：
     - MESSAGE CONTENT INTENT
   - 设置所需权限（管理员或相应权限）

3. **邀请机器人到服务器**：
   - 进入 OAuth2 → URL Generator
   - 勾选 `bot` 权限
   - 生成 URL 并访问

4. **配置 OpenClaw**：

```bash
openclaw channels add
```

选择 **Discord**，输入 Bot Token

或手动配置：

```json
{
  "channels": {
    "discord": {
      "enabled": true,
      "token": "你的BotToken"
    }
  }
}
```

---

## 常见问题

### 渠道无法连接？

1. 检查网关是否运行：
```bash
openclaw gateway status
```

2. 查看日志：
```bash
openclaw logs --follow
```

3. 重启网关：
```bash
openclaw gateway restart
```

### 收不到消息？

1. 检查配置是否正确
2. 检查应用是否发布
3. 检查权限是否完整
4. 查看日志排查

### 如何切换多个渠道？

```bash
openclaw channels list
```

### 如何禁用某个渠道？

编辑配置文件，设置 `enabled: false`：

```json
{
  "channels": {
    "telegram": {
      "enabled": false
    }
  }
}
```

---

## 更多帮助

- 官方文档: https://docs.openclaw.ai/zh-CN/channels
- Discord 社区: https://discord.gg/clawd
- GitHub Issues: https://github.com/openclaw/openclaw/issues
