#!/bin/bash
set -e

# MightyRaju One-Click Setup Script
# Installs OpenClaw, configures Kimi/NIM/OpenRouter, and sets up MightyRaju skills.

echo "🦞 Welcome to the MightyRaju OpenClaw Installer!"
echo "This script will set up a full AI assistant on your Linux machine."
echo "You will need: Telegram Bot Token, NVIDIA NIM or OpenRouter API Key."
echo "----------------------------------------------------------------"

# 1. Install System Dependencies
echo "[1/6] Installing system dependencies..."
if [ -x "$(command -v apt-get)" ]; then
    sudo apt-get update -qq
    sudo apt-get install -y curl git ripgrep bc jq build-essential
else
    echo "⚠️  Not on Debian/Ubuntu? Please install: curl git ripgrep bc jq manually."
fi

# 2. Install Node.js (via nvm)
echo "[2/6] Installing Node.js..."
if [ -z "$NVM_DIR" ]; then
    export NVM_DIR="$HOME/.nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi
nvm install 22
nvm use 22
nvm alias default 22

# 3. Install OpenClaw
echo "[3/6] Installing OpenClaw..."
npm install -g openclaw

# 4. Clone MightyRaju Config
echo "[4/6] Downloading MightyRaju configuration..."
# Clone to a temporary directory if not already inside the repo
if [ ! -f "openclaw.json.example" ]; then
    git clone https://github.com/Ryuki0x1/openclaw-free-kimi-api.git ~/mightyraju-setup
    cd ~/mightyraju-setup
fi

# Create OpenClaw directories
mkdir -p ~/.openclaw/scripts ~/.openclaw/skills
cp -r scripts/* ~/.openclaw/scripts/
cp -r skills/* ~/.openclaw/skills/

# 5. Configuration Wizard
echo "[5/6] Configuring your Assistant..."
echo ""

read -p "Enter your Telegram Bot Token (from @BotFather): " TG_TOKEN
if [ -z "$TG_TOKEN" ]; then echo "❌ Bot Token is required!"; exit 1; fi

echo ""
echo "Choose your AI Provider:"
echo "1) NVIDIA NIM (Free Kimi k2.5) [Recommended]"
echo "2) OpenRouter (DeepSeek/Llama/etc)"
read -p "Select [1/2]: " PROVIDER_CHOICE

if [ "$PROVIDER_CHOICE" == "2" ]; then
    read -p "Enter your OpenRouter API Key: " API_KEY
    BASE_URL="https://openrouter.ai/api/v1"
    MODEL_ID="deepseek/deepseek-chat" # Default to DeepSeek v3
else
    read -p "Enter your NVIDIA NIM API Key (starts with nvapi-): " API_KEY
    BASE_URL="https://integrate.api.nvidia.com/v1"
    MODEL_ID="moonshotai/kimi-k2.5"
fi

read -p "Enter your Telegram User ID (numeric, from @userinfobot): " OWNER_ID

# Generate Config Files
echo "Generating config..."

# Generate Gateway Auth Token
GATEWAY_TOKEN=$(openssl rand -hex 16)

# Create openclaw.json
cat > ~/.openclaw/openclaw.json <<EOF
{
  "meta": { "lastTouchedVersion": "2026.2.17" },
  "models": {
    "mode": "merge",
    "providers": {
      "custom-provider": {
        "baseUrl": "$BASE_URL",
        "apiKey": "$API_KEY",
        "api": "openai-completions",
        "models": [
          {
            "id": "$MODEL_ID",
            "name": "MightyRaju Model",
            "reasoning": false,
            "input": ["text"],
            "contextWindow": 131072,
            "maxTokens": 8192
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": { "primary": "custom-provider/$MODEL_ID" },
      "workspace": "$HOME/.openclaw/workspace",
      "compaction": { "mode": "safeguard" }
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "pairing",
      "botToken": "$TG_TOKEN",
      "groupPolicy": "allowlist"
    }
  },
  "gateway": {
    "port": 41592,
    "mode": "local",
    "bind": "loopback",
    "auth": { "mode": "token", "token": "$GATEWAY_TOKEN" }
  },
  "plugins": { "entries": { "telegram": { "enabled": true } } }
}
EOF

# Create Access Whitelist
cat > ~/.openclaw/access-whitelist.json <<EOF
{
  "owner": "$OWNER_ID",
  "allowed_users": [
    { "id": "$OWNER_ID", "name": "owner", "added_at": "$(date -Iseconds)" }
  ]
}
EOF

# 6. Start Service
echo "[6/6] Starting MightyRaju..."
openclaw daemon start

echo ""
echo "🎉 Setup Complete! Your AI is running."
echo "👉 Telegram Bot is active. Message it to start!"
echo "👉 Owner ID $OWNER_ID is whitelisted."
echo "👉 Gateway running on localhost:41592"
