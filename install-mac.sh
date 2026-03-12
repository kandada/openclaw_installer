#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  OpenClaw macOS 安装程序${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

check_command() {
    command -v "$1" >/dev 2>&1
}

install_nodejs() {
    echo -e "${YELLOW}正在自动安装 Node.js...${NC}"
    
    if check_command brew; then
        echo "使用 Homebrew 安装 Node.js..."
        brew install node@22
        
        # 刷新 path
        export PATH="/usr/local/opt/node@22/bin:$PATH"
        export PATH="/opt/homebrew/opt/node@22/bin:$PATH"
        
        echo -e "${GREEN}✓ Node.js 已安装${NC}"
    else
        echo "未检测到 Homebrew，尝试直接下载..."
        
        # 下载 Node.js
        NODE_VERSION="22.14.0"
        ARCH="arm64"
        
        if [[ "$(uname -m)" == "x86_64" ]]; then
            ARCH="x64"
        fi
        
        cd /tmp
        curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-darwin-${ARCH}.pkg" -o node.pkg
        
        echo "安装 Node.js 包..."
        sudo installer -pkg node.pkg -target /
        
        rm -f node.pkg
        
        # 刷新 path
        export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"
        
        echo -e "${GREEN}✓ Node.js 已安装${NC}"
    fi
    
    # 验证安装
    if check_command node; then
        echo -e "${GREEN}Node.js 版本: $(node -v)${NC}"
    else
        echo -e "${RED}Node.js 安装后需要重新打开终端才能生效${NC}"
        echo -e "${YELLOW}请关闭终端重新打开，然后再次运行此脚本${NC}"
        exit 1
    fi
}

echo -e "${YELLOW}[1/6] 检查系统要求...${NC}"

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}错误: 此脚本仅适用于 macOS 系统${NC}"
    exit 1
fi

# 检查并自动安装 Node.js
if ! check_command node; then
    echo -e "${YELLOW}未检测到 Node.js${NC}"
    install_nodejs
else
    NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_VERSION" -lt 22 ]; then
        echo -e "${YELLOW}Node.js 版本过低 (v$(node -v))，正在升级...${NC}"
        install_nodejs
    else
        echo -e "${GREEN}✓ Node.js 版本: $(node -v)${NC}"
    fi
fi

# 再次检查 Node.js
if ! check_command node; then
    echo -e "${RED}无法使用 node 命令，请重新打开终端后重试${NC}"
    exit 1
fi

echo -e "${YELLOW}[2/6] 安装 OpenClaw...${NC}"

if check_command openclaw; then
    echo -e "${YELLOW}OpenClaw 已存在，是否升级?${NC}"
    read -p "升级到最新版本? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if check_command pnpm; then
            pnpm add -g openclaw@latest
        else
            npm install -g openclaw@latest
        fi
        echo -e "${GREEN}✓ OpenClaw 已升级${NC}"
    fi
else
    if check_command pnpm; then
        pnpm add -g openclaw@latest
    else
        npm install -g openclaw@latest
    fi
    echo -e "${GREEN}✓ OpenClaw 已安装${NC}"
fi

echo -e "${YELLOW}[3/6] 配置模型认证...${NC}"

CONFIG_FILE="$HOME/.openclaw/openclaw.json"
mkdir -p "$HOME/.openclaw"

if [ -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}检测到已有配置文件${NC}"
    read -p "是否重新配置模型? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "跳过模型配置"
    else
        openclaw configure --section model
    fi
else
    echo -e "${YELLOW}请选择模型提供商:${NC}"
    echo "1) Anthropic (Claude) - 推荐"
    echo "2) OpenAI (GPT)"
    echo "3) OpenCode Zen"
    echo "4) MiniMax"
    echo "5) 稍后配置"
    read -p "选择 (1-5): " choice
    
    case $choice in
        1)
            read -p "输入 Anthropic API Key: " API_KEY
            if [ -n "$API_KEY" ]; then
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
                echo -e "${GREEN}✓ Anthropic 配置已保存${NC}"
            fi
            ;;
        2)
            read -p "输入 OpenAI API Key: " API_KEY
            if [ -n "$API_KEY" ]; then
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
                echo -e "${GREEN}✓ OpenAI 配置已保存${NC}"
            fi
            ;;
        3)
            read -p "输入 OpenCode Zen API Key: " API_KEY
            if [ -n "$API_KEY" ]; then
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
                echo -e "${GREEN}✓ OpenCode Zen 配置已保存${NC}"
            fi
            ;;
        4)
            read -p "输入 MiniMax API Key: " API_KEY
            if [ -n "$API_KEY" ]; then
                cat > "$CONFIG_FILE" << EOF
{
  "agents": {
    "defaults": {
      "model": "minimax/MiniMax-M2.1"
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
                echo -e "${GREEN}✓ MiniMax 配置已保存${NC}"
            fi
            ;;
        *)
            echo "跳过模型配置，可稍后使用 openclaw configure 配置"
            ;;
    esac
fi

echo -e "${YELLOW}[4/6] 安装常用 Skills...${NC}"

read -p "是否安装常用 Skills? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "安装热门 Skills..."
    
    if check_command clawhub; then
        echo "从 ClawHub 安装热门 Skills..."
        echo "常用 Skills: web-search, summarize, browser"
    else
        echo "安装 clawhub 工具..."
        npm install -g clawhub
    fi
    
    echo -e "${YELLOW}推荐安装以下 Skills:${NC}"
    echo "  - web-search: 网页搜索"
    echo "  - summarize: 内容摘要"
    echo "  - browser: 浏览器控制"
    echo ""
    echo "安装命令: clawhub install <skill-name>"
fi

echo -e "${YELLOW}[5/6] 启动引导配置...${NC}"

read -p "是否运行引导配置向导? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}启动向导 (openclaw onboard)...${NC}"
    echo -e "${YELLOW}此向导将引导您完成:${NC}"
    echo "  - 工作区设置"
    echo "  - 网关配置"
    echo "  - 渠道配置 (WhatsApp/Telegram/Discord/飞书等)"
    echo "  - 后台服务安装"
    echo ""
    openclaw onboard --install-daemon
else
    echo -e "${YELLOW}跳过引导配置，您可稍后运行: openclaw onboard --install-daemon${NC}"
fi

echo -e "${YELLOW}[6/6] 完成!${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  OpenClaw 安装完成!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "快速开始:"
echo "  1. 启动网关: openclaw gateway --port 18789"
echo "  2. 打开控制台: openclaw dashboard"
echo "  3. 访问: http://127.0.0.1:18789"
echo ""
echo "更多配置请查看 README.md"
echo ""

read -p "是否立即启动网关? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    openclaw gateway --port 18789
fi
