#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CONFIG_FILE="$HOME/.openclaw/openclaw.json"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  OpenClaw 配置向导${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

check_command() {
    command -v "$1" >/dev/null 2>&1
}

echo -e "${YELLOW}[1/4] 配置模型...${NC}"

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}未检测到配置文件，请先运行安装脚本或 openclaw onboard${NC}"
fi

echo -e "${BLUE}请选择要配置的内容:${NC}"
echo "1) 配置 Anthropic (Claude)"
echo "2) 配置 OpenAI"
echo "3) 配置 OpenCode Zen"
echo "4) 配置 MiniMax"
echo "5) 配置 Brave Search (网页搜索)"
echo "6) 查看当前配置"
echo "7) 退出"
read -p "选择 (1-7): " choice

case $choice in
    1)
        read -p "输入 Anthropic API Key: " API_KEY
        if [ -n "$API_KEY" ]; then
            if [ -f "$CONFIG_FILE" ]; then
                TEMP=$(mktemp)
                jq ".agents.defaults.model = \"anthropic/claude-sonnet-4-20250514\" | .models.providers.anthropic.apiKey = \"$API_KEY\"" "$CONFIG_FILE" > "$TEMP" && mv "$TEMP" "$CONFIG_FILE"
            else
                cat > "$CONFIG_FILE" << EOF
{
  "agents": {
    "defaults": {
      "model": "anthropic/claude-sonnet-4-20250514"
    }
  },
  "models": {
    "providers": {
      "anthropic": {
        "apiKey": "$API_KEY"
      }
    }
  }
}
EOF
            fi
            echo -e "${GREEN}✓ Anthropic 配置已保存${NC}"
        fi
        ;;
    2)
        read -p "输入 OpenAI API Key: " API_KEY
        if [ -n "$API_KEY" ]; then
            if [ -f "$CONFIG_FILE" ]; then
                TEMP=$(mktemp)
                jq ".agents.defaults.model = \"openai/gpt-4o\" | .models.providers.openai.apiKey = \"$API_KEY\"" "$CONFIG_FILE" > "$TEMP" && mv "$TEMP" "$CONFIG_FILE"
            else
                cat > "$CONFIG_FILE" << EOF
{
  "agents": {
    "defaults": {
      "model": "openai/gpt-4o"
    }
  },
  "models": {
    "providers": {
      "openai": {
        "apiKey": "$API_KEY"
      }
    }
  }
}
EOF
            fi
            echo -e "${GREEN}✓ OpenAI 配置已保存${NC}"
        fi
        ;;
    3)
        read -p "输入 OpenCode Zen API Key: " API_KEY
        if [ -n "$API_KEY" ]; then
            if [ -f "$CONFIG_FILE" ]; then
                TEMP=$(mktemp)
                jq ".agents.defaults.model = \"opencode-zen/default\" | .models.providers.\"opencode-zen\".apiKey = \"$API_KEY\"" "$CONFIG_FILE" > "$TEMP" && mv "$TEMP" "$CONFIG_FILE"
            else
                cat > "$CONFIG_FILE" << EOF
{
  "agents": {
    "defaults": {
      "model": "opencode-zen/default"
    }
  },
  "models": {
    "providers": {
      "opencode-zen": {
        "apiKey": "$API_KEY"
      }
    }
  }
}
EOF
            fi
            echo -e "${GREEN}✓ OpenCode Zen 配置已保存${NC}"
        fi
        ;;
    4)
        read -p "输入 MiniMax API Key: " API_KEY
        if [ -n "$API_KEY" ]; then
            if [ -f "$CONFIG_FILE" ]; then
                TEMP=$(mktemp)
                jq ".agents.defaults.model = \"minimax/MiniMax-M2.1\" | .models.providers.minimax.apiKey = \"$API_KEY\"" "$CONFIG_FILE" > "$TEMP" && mv "$TEMP" "$CONFIG_FILE"
            else
                cat > "$CONFIG_FILE" << EOF
{
  "agents":": {
      "model": "minimax/MiniMax {
    "defaults-M2.1"
    }
  },
  "models": {
    "providers": {
      "minimax": {
        "apiKey": "$API_KEY"
      }
    }
  }
}
EOF
            fi
            echo -e "${GREEN}✓ MiniMax 配置已保存${NC}"
        fi
        ;;
    5)
        read -p "输入 Brave Search API Key: " API_KEY
        if [ -n "$API_KEY" ]; then
            if [ -f "$CONFIG_FILE" ]; then
                TEMP=$(mktemp)
                jq ".tools.web.search.apiKey = \"$API_KEY\"" "$CONFIG_FILE" > "$TEMP" && mv "$TEMP" "$CONFIG_FILE"
            else
                cat > "$CONFIG_FILE" << EOF
{
  "tools": {
    "web": {
      "search": {
        "apiKey": "$API_KEY"
      }
    }
  }
}
EOF
            fi
            echo -e "${GREEN}✓ Brave Search 配置已保存${NC}"
        fi
        ;;
    6)
        if [ -f "$CONFIG_FILE" ]; then
            echo -e "${BLUE}当前配置:${NC}"
            cat "$CONFIG_FILE"
        else
            echo -e "${YELLOW}未找到配置文件${NC}"
        fi
        ;;
    *)
        echo "退出"
        exit 0
        ;;
esac

echo -e "${YELLOW}[2/4] 安装 Skills...${NC}"

if ! check_command clawhub; then
    echo "安装 clawhub..."
    npm install -g clawhub
fi

echo -e "${BLUE}热门 Skills 推荐:${NC}"
echo "  - web-search: 网页搜索"
echo "  - summarize: 内容摘要"
echo "  - browser: 浏览器控制"
echo "  - github: GitHub 操作"
echo "  - executor: 命令执行"
echo ""
read -p "输入要安装的 Skills (空格分隔，可留空): " skills_input

if [ -n "$skills_input" ]; then
    for skill in $skills_input; do
        echo "安装 $skill..."
        clawhub install "$skill" 2>/dev/null || echo "  无法安装 $skill，请检查名称是否正确"
    done
fi

echo -e "${YELLOW}[3/4] 配置渠道...${NC}"

echo -e "${BLUE}可选渠道:${NC}"
echo "1) 飞书 (Feishu)"
echo "2) Telegram"
echo "3) WhatsApp"
echo "4) Discord"
echo "5) 跳过"
read -p "选择要配置的渠道 (1-5): " channel_choice

case $channel_choice in
    1)
        echo -e "${BLUE}飞书配置指南:${NC}"
        echo "1. 访问 https://open.feishu.cn/app 创建应用"
        echo "2. 获取 App ID 和 App Secret"
        echo "3. 配置权限: im:message, im:chat 等"
        echo "4. 启用机器人能力"
        echo "5. 配置事件订阅 (长连接模式)"
        echo ""
        read -p "输入飞书 App ID (cli_xxx): " APP_ID
        read -p "输入飞书 App Secret: " APP_SECRET
        
        if [ -n "$APP_ID" ] && [ -n "$APP_SECRET" ]; then
            if [ -f "$CONFIG_FILE" ]; then
                TEMP=$(mktemp)
                jq ".channels.feishu = { enabled: true, dmPolicy: \"pairing\", accounts: { main: { appId: \"$APP_ID\", appSecret: \"$APP_SECRET\" } } }" "$CONFIG_FILE" > "$TEMP" && mv "$TEMP" "$CONFIG_FILE"
            else
                cat > "$CONFIG_FILE" << EOF
{
  "channels": {
    "feishu": {
      "enabled": true,
      "dmPolicy": "pairing",
      "accounts": {
        "main": {
          "appId": "$APP_ID",
          "appSecret": "$APP_SECRET"
        }
      }
    }
  }
}
EOF
            fi
            echo -e "${GREEN}✓ 飞书配置已保存${NC}"
            echo -e "${YELLOW}请在飞书开放平台发布应用并配置事件订阅${NC}"
        fi
        ;;
    2)
        read -p "输入 Telegram Bot Token: " BOT_TOKEN
        if [ -n "$BOT_TOKEN" ]; then
            if [ -f "$CONFIG_FILE" ]; then
                TEMP=$(mktemp)
                jq ".channels.telegram = { enabled: true, botToken: \"$BOT_TOKEN\" }" "$CONFIG_FILE" > "$TEMP" && mv "$TEMP" "$CONFIG_FILE"
            else
                cat > "$CONFIG_FILE" << EOF
{
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "$BOT_TOKEN"
    }
  }
}
EOF
            fi
            echo -e "${GREEN}✓ Telegram 配置已保存${NC}"
        fi
        ;;
    3)
        echo "WhatsApp 需要通过 QR 码登录"
        echo "运行: openclaw channels login"
        ;;
    4)
        read -p "输入 Discord Bot Token: " DISCORD_TOKEN
        if [ -n "$DISCORD_TOKEN" ]; then
            if [ -f "$CONFIG_FILE" ]; then
                TEMP=$(mktemp)
                jq ".channels.discord = { enabled: true, token: \"$DISCORD_TOKEN\" }" "$CONFIG_FILE" > "$TEMP" && mv "$TEMP" "$CONFIG_FILE"
            else
                cat > "$CONFIG_FILE" << EOF
{
  "channels": {
    "discord": {
      "enabled": true,
      "token": "$DISCORD_TOKEN"
    }
  }
}
EOF
            fi
            echo -e "${GREEN}✓ Discord 配置已保存${NC}"
        fi
        ;;
    *)
        echo "跳过渠道配置"
        ;;
esac

echo -e "${YELLOW}[4/4] 启动网关...${NC}"

read -p "是否启动网关? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    openclaw gateway --port 18789
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  配置完成!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "常用命令:"
echo "  - openclaw status: 查看状态"
echo "  - openclaw health: 健康检查"
echo "  - openclaw dashboard: 打开控制台"
echo "  - openclaw logs --follow: 查看日志"
echo ""
