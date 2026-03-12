# OpenClaw 一键安装包

双击即可完成安装，无需任何命令行操作！

---

## 下载使用

### Windows 用户
**双击 `OpenClaw-Setup.bat`**

### macOS 用户
**双击 `install-mac.sh`**

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

### 飞书接入
1. 访问 [飞书开放平台](https://open.feishu.cn/app) 创建应用
2. 获取 App ID 和 App Secret
3. 运行: `openclaw channels add` → 选择 Feishu

### Telegram/WhatsApp/Discord
运行: `openclaw channels add` 按提示配置

---

## 文件结构

```
openclaw_installer/
├── OpenClaw-Setup.bat   # Windows 双击运行
├── install-mac.sh       # macOS 双击运行
├── install-windows.ps1  # Windows 安装脚本
├── setup-guided.sh      # 配置向导
└── README.md            # 详细说明
```

---

## 常见问题

**Windows 双击没反应？**
- 右键 → "使用 PowerShell 运行"

**macOS 无法运行？**
- 右键 → "打开" → 确认运行

---

## 技术支持

- 官方文档: https://docs.openclaw.ai/zh-CN
- Discord: https://discord.gg/clawd
