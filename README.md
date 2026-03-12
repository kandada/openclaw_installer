# OpenClaw 一键安装包

双击即可完成安装，无需任何命令行操作！

---

## 文件说明

```
openclaw_installer/
├── OpenClaw-Setup.bat   # ← Windows 双击运行
├── install-mac.sh       # ← macOS 双击运行
├── install-windows.ps1  # Windows 安装脚本
├── setup-guided.sh      # 配置向导
├── CHANNELS.md          # 渠道配置详细指南
└── README.md            # 本文件
```

---

## 使用方法

### Windows
**双击 `OpenClaw-Setup.bat`**

### macOS
**双击 `install-mac.sh`**

（如果提示"无法运行"，右键 → "打开" → 确认运行）

---

## 安装流程

安装程序会自动完成：

1. ✅ 自动检测并安装 Node.js 22（如未安装）
2. ✅ 安装 OpenClaw
3. ✅ 配置 AI 模型（可选 Anthropic/OpenAI/OpenCode Zen）
4. ✅ 安装常用 Skills
5. ✅ 运行引导配置

---

## 安装完成后

打开浏览器访问: **http://127.0.0.1:18789**

---

## 配置消息渠道

### 飞书机器人

详细配置指南：[CHANNELS.md](CHANNELS.md书机器人)

快速开始：
1. 访问 [飞书开放平台](https://open.feishu.cn/app) 创建应用
2. 获取 App ID 和 App Secret
3. 配置权限和事件订阅
4. 运行: `openclaw channels add` → 选择 Feishu

### iMessage

详细配置指南：[CHANNELS.md](CHANNELS.mdmessage)

- **macOS 本地**: 使用 BlueBubbles 或 imsg
- **远程**: 使用 BlueBubbles 服务器

### Telegram

1. 联系 @BotFather 创建机器人
2. 获取 Bot Token
3. 运行: `openclaw channels add` → 选择 Telegram

### WhatsApp

运行: `openclaw channels login` → 扫描 QR 码

### Discord

1. 在 Discord Developer Portal 创建应用
2. 获取 Bot Token
3. 运行: `openclaw channels add` → 选择 Discord

---

## 常用命令

```bash
# 查看状态
openclaw status

# 启动网关
openclaw gateway --port 18789

# 查看日志
openclaw logs --follow

# 添加渠道
openclaw channels add

# 配对审批
openclaw pairing approve <渠道> <配对码>
```

---

## 常见问题

**Windows 双击没反应？**
- 右键 → "使用 PowerShell 运行"

**macOS 无法运行？**
- 右键 → "打开" → 确认运行

**收不到消息？**
- 检查网关状态: `openclaw gateway status`
- 查看日志: `openclaw logs --follow`

---

## 技术支持

- 官方文档: https://docs.openclaw.ai/zh-CN
- Discord: https://discord.gg/clawd
- GitHub: https://github.com/openclaw/openclaw
