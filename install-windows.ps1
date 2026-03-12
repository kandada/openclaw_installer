# OpenClaw Windows Installer Script
# Requires PowerShell 5.1+
# 自动安装 Node.js 和必要依赖

param(
    [switch]$SkipWizard,
    [switch]$SkipSkills,
    [string]$ApiKey = ""
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Test-Command {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Install-NodeJs {
    Write-Host ""
    Write-Host "正在自动安装 Node.js..." -ForegroundColor Yellow
    
    $nodeVersion = "22.14.0"
    $arch = "x64"
    $os = "win"
    $extension = "msi"
    
    # 检测系统架构
    if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
        $arch = "arm64"
    }
    
    $downloadUrl = "https://nodejs.org/dist/v$nodeVersion/node-v$nodeVersion-$os-$arch.$extension"
    $installerPath = "$env:TEMP\node-v$nodeVersion-$arch.$extension"
    
    Write-Host "下载 Node.js v$nodeVersion..." -ForegroundColor Cyan
    Write-Host "URL: $downloadUrl"
    
    try {
        # 使用 BITS 后台下载
        Start-BitsTransfer -Source $downloadUrl -Destination $installerPath -ErrorAction Stop
        Write-Success "下载完成"
        
        # 安装 Node.js (静默安装)
        Write-Host "正在安装 Node.js..." -ForegroundColor Cyan
        $installArgs = "/quiet /norestart ADDLOCAL=All"
        
        $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installerPath`" $installArgs" -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            Write-Success "Node.js 安装成功"
            
            # 刷新环境变量
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            
            # 等待几秒让安装完成
            Start-Sleep -Seconds 3
            
            # 验证安装
            if (Test-Command "node") {
                Write-Success "Node.js 版本: $(node --version)"
            }
        } else {
            Write-Warn "Node.js 安装可能未完全成功，尝试其他方法..."
        }
        
        # 清理安装文件
        Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
        
    } catch {
        Write-Warn "自动下载失败，尝试使用 winget..."
        
        # 尝试使用 winget
        if (Test-Command "winget") {
            Write-Host "使用 winget 安装 Node.js..." -ForegroundColor Cyan
            winget install OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
            
            # 刷新环境变量
            Start-Sleep -Seconds 3
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            
            if (Test-Command "node") {
                Write-Success "Node.js 版本: $(node --version)"
            }
        } else {
            # winget 不可用，尝试 chocolatey
            if (Test-Command "choco") {
                Write-Host "使用 chocolatey 安装 Node.js..." -ForegroundColor Cyan
                choco install nodejs-lts -y
                
                # 刷新环境变量
                Start-Sleep -Seconds 3
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
                
                if (Test-Command "node") {
                    Write-Success "Node.js 版本: $(node --version)"
                }
            } else {
                Write-Error "无法自动安装 Node.js"
                Write-Host ""
                Write-Host "请手动安装 Node.js:" -ForegroundColor Yellow
                Write-Host "1. 访问 https://nodejs.org 下载 LTS 版本" -ForegroundColor Yellow
                Write-Host "2. 运行安装程序" -ForegroundColor Yellow
                Write-Host "3. 重新运行此脚本" -ForegroundColor Yellow
                exit 1
            }
        }
    }
}

function Install-Pnpm {
    Write-Host "正在安装 pnpm..." -ForegroundColor Cyan
    npm install -g pnpm
    if (Test-Command "pnpm") {
        Write-Success "pnpm 已安装"
    } else {
        Write-Warn "pnpm 安装可能失败，npm 仍可用"
    }
}

# 主流程开始
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenClaw Windows 安装程序" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Step "检查系统要求"

if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Error "需要 PowerShell 5.1 或更高版本"
    exit 1
}

Write-Success "PowerShell 版本: $($PSVersionTable.PSVersion)"

# 检查并自动安装 Node.js
if (-not (Test-Command "node")) {
    Write-Warn "未检测到 Node.js"
    Write-Host "将自动安装 Node.js LTS 版本..." -ForegroundColor Yellow
    Install-NodeJs
    
    # 再次检查
    if (-not (Test-Command "node")) {
        Write-Error "Node.js 安装失败，请手动安装后重试"
        exit 1
    }
} else {
    $nodeVersion = node --version
    Write-Success "Node.js 版本: $nodeVersion"
    
    $versionNum = [int]($nodeVersion -replace 'v','' -replace '\..*','')
    if ($versionNum -lt 22) {
        Write-Warn "Node.js 版本低于 22，将自动升级..."
        Install-NodeJs
    }
}

# 验证 Node.js
if (Test-Command "node") {
    Write-Success "Node.js 已就绪: $(node --version)"
}

Write-Step "安装 OpenClaw"

if (Test-Command "openclaw") {
    Write-Host "OpenClaw 已存在" -ForegroundColor Yellow
    $upgrade = Read-Host "是否升级到最新版本? (y/n)"
    if ($upgrade -eq "y") {
        if (Test-Command "pnpm") {
            pnpm add -g openclaw@latest
        } else {
            npm install -g openclaw@latest
        }
        Write-Success "OpenClaw 已升级"
    }
} else {
    Write-Host "正在安装 OpenClaw..." -ForegroundColor Cyan
    if (Test-Command "pnpm") {
        pnpm add -g openclaw@latest
    } else {
        npm install -g openclaw@latest
    }
    
    if (Test-Command "openclaw") {
        Write-Success "OpenClaw 已安装"
    } else {
        Write-Error "OpenClaw 安装失败"
        exit 1
    }
}

Write-Step "配置模型认证"

$CONFIG_FILE = "$env:USERPROFILE\.openclaw\openclaw.json"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.openclaw" | Out-Null

if (Test-Path $CONFIG_FILE) {
    Write-Warn "检测到已有配置文件"
    $reconfigure = Read-Host "是否重新配置模型? (y/n)"
    if ($reconfigure -eq "y") {
        openclaw configure --section model
    }
} else {
    Write-Host "请选择模型提供商:" -ForegroundColor Yellow
    Write-Host "1) Anthropic (Claude) - 推荐"
    Write-Host "2) OpenAI (GPT)"
    Write-Host "3) OpenCode Zen"
    Write-Host "4) MiniMax"
    Write-Host "5) 稍后配置"
    
    $choice = Read-Host "选择 (1-5)"
    
    switch ($choice) {
        "1" {
            if ($ApiKey) { $apiKeyInput = $ApiKey } else { $apiKeyInput = Read-Host "输入 Anthropic API Key" }
            if ($apiKeyInput) {
                @{
                    agents = @{ defaults = @{ model = "anthropic/claude-sonnet-4-20250514" } }
                    models = @{ providers = @{ anthropic = @{ apiKey = $apiKeyInput } } }
                } | ConvertTo-Json -Depth 10 | Set-Content $CONFIG_FILE
                Write-Success "Anthropic 配置已保存"
            }
        }
        "2" {
            if ($ApiKey) { $apiKeyInput = $ApiKey } else { $apiKeyInput = Read-Host "输入 OpenAI API Key" }
            if ($apiKeyInput) {
                @{
                    agents = @{ defaults = @{ model = "openai/gpt-4o" } }
                    models = @{ providers = @{ openai = @{ apiKey = $apiKeyInput } } }
                } | ConvertTo-Json -Depth 10 | Set-Content $CONFIG_FILE
                Write-Success "OpenAI 配置已保存"
            }
        }
        "3" {
            if ($ApiKey) { $apiKeyInput = $ApiKey } else { $apiKeyInput = Read-Host "输入 OpenCode Zen API Key" }
            if ($apiKeyInput) {
                @{
                    agents = @{ defaults = @{ model = "opencode-zen/default" } }
                    models = @{ providers = @{ "opencode-zen" = @{ apiKey = $apiKeyInput } } }
                } | ConvertTo-Json -Depth 10 | Set-Content $CONFIG_FILE
                Write-Success "OpenCode Zen 配置已保存"
            }
        }
        "4" {
            if ($ApiKey) { $apiKeyInput = $ApiKey } else { $apiKeyInput = Read-Host "输入 MiniMax API Key" }
            if ($apiKeyInput) {
                @{
                    agents = @{ defaults = @{ model = "minimax/MiniMax-M2.1" } }
                    models = @{ providers = @{ minimax = @{ apiKey = $apiKeyInput } } }
                } | ConvertTo-Json -Depth 10 | Set-Content $CONFIG_FILE
                Write-Success "MiniMax 配置已保存"
            }
        }
        default {
            Write-Host "跳过模型配置，可稍后使用 openclaw configure 配置" -ForegroundColor Yellow
        }
    }
}

if (-not $SkipSkills) {
    Write-Step "安装常用 Skills"
    
    $installSkills = Read-Host "是否安装常用 Skills? (y/n)"
    if ($installSkills -eq "y") {
        if (-not (Test-Command "clawhub")) {
            Write-Host "安装 clawhub 工具..." -ForegroundColor Cyan
            npm install -g clawhub
        }
        
        Write-Host "推荐 Skills:" -ForegroundColor Yellow
        Write-Host "  - web-search: 网页搜索"
        Write-Host "  - summarize: 内容摘要"
        Write-Host "  - browser: 浏览器控制"
        Write-Host ""
        Write-Host "安装命令: clawhub install <skill-name>"
    }
}

if (-not $SkipWizard) {
    Write-Step "启动引导配置"
    
    $runWizard = Read-Host "是否运行引导配置向导? (y/n)"
    if ($runWizard -eq "y") {
        Write-Host "启动向导..." -ForegroundColor Yellow
        Write-Host "此向导将引导您完成工作区、网关、渠道配置" -ForegroundColor Yellow
        
        openclaw onboard --install-daemon
    }
}

Write-Step "安装完成"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  OpenClaw 安装完成!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "快速开始:" -ForegroundColor Cyan
Write-Host "  1. 启动网关: openclaw gateway --port 18789"
Write-Host "  2. 打开控制台: openclaw dashboard"
Write-Host "  3. 访问: http://127.0.0.1:18789"
Write-Host ""
Write-Host "配置渠道:" -ForegroundColor Cyan
Write-Host "  openclaw channels add"
Write-Host ""
Write-Host "更多帮助: https://docs.openclaw.ai/zh-CN" -ForegroundColor Cyan
Write-Host ""

$startGateway = Read-Host "是否立即启动网关? (y/n)"
if ($startGateway -eq "y") {
    openclaw gateway --port 18789
}
