# 🦞 Build Your Own "Jarvis" with OpenClaw & Free Kimi 2.5 API (MightyRaju)

Turn an idle Linux server (or Raspberry Pi) into a powerful, always-on AI assistant named **MightyRaju**.

This project uses [OpenClaw](https://github.com/google-deepmind/openclaw) as the agent framework and the **free tier of Moonshot AI's Kimi k2.5 model** (via NVIDIA NIM) to create a smart, responsive assistant.

## 🚀 Why This Stack?

- **OpenClaw**: The most capable open-source agent runtime.
- **Kimi k2.5 (NVIDIA NIM)**: A massive 128k context model that rivals GPT-4 class models, available for **free** (at the time of writing) via NVIDIA's API catalog.
- **Alternative (OpenRouter)**: Access to free models like `deepseek/deepseek-chat-v3`.
- **Telegram**: The perfect mobile interface for a secure, always-on bot.
- **Linux**: Runs on anything from a cheap VPS to an old laptop or Raspberry Pi.

---

## 🛠️ Step 1: Preparation (Get Your Keys)

Before installing anything, you need to gather a few free keys.

### 🤖 1. Create Your Telegram Bot
1. Open Telegram and search for **[@BotFather](https://t.me/BotFather)**.
2. Send the command `/newbot`.
3. Follow the prompts to name your bot (e.g., `MyJarvisBot`).
4. **Copy the API Token** it gives you (looks like `123456:ABC-DEF...`).

### 🆔 2. Get Your User ID
1. Search for **[@userinfobot](https://t.me/userinfobot)**.
2. Click "Start".
3. **Copy your numeric ID** (e.g., `1963980883`). You need this to whitelist yourself so no one else can control your bot.

### 🔑 3. Get Your AI API Key

#### Option A: NVIDIA NIM (Recommended for Kimi k2.5)
1. Go to [build.nvidia.com](https://build.nvidia.com/moonshot-ai/kimi-k2-5).
2. Click **"Get API Key"**.
3. Create a free NVIDIA Developer account.
4. Copy the key (starts with `nvapi-...`).

#### Option B: OpenRouter (Alternative)
1. Go to [openrouter.ai](https://openrouter.ai/).
2. Sign up and go to **Keys**.
3. Create a key.

---

## ⚡ Step 2: Fast Deployment (One-Click)

Once you have your keys, run this specialized script. It installs dependencies, Node.js, OpenClaw, and configures everything for you interactively.

1. **Run the Installer**:
   ```bash
   curl -sL https://raw.githubusercontent.com/Ryuki0x1/openclaw-free-kimi-api/master/setup.sh | bash
   ```
2. **Follow the Prompts**:
   - Paste your **Telegram Bot Token**.
   - Choose **NVIDIA NIM** (for Kimi) or **OpenRouter**.
   - Paste your **API Key**.
   - Enter your **Telegram User ID** (to secure the bot).

The script will generate secure config files, install all skills, and start the daemon automatically.

---

## 🛠️ Manual Installation (Alternative)

If you prefer to do it step-by-step:

### 1. Install System Tools
On Debian/Ubuntu:
```bash
sudo apt update
sudo apt install -y curl git ripgrep bc jq
```

### 2. Install OpenClaw
```bash
# Install nvm if you haven't
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install 22
nvm use 22

# Install OpenClaw globally
npm install -g openclaw
```

### 3. Clone This Repo
```bash
git clone https://github.com/Ryuki0x1/openclaw-free-kimi-api.git mightyraju
cd mightyraju
```

### 4. Setup Configuration
Copy the template files to your OpenClaw directory:

```bash
# Create directories
mkdir -p ~/.openclaw/scripts ~/.openclaw/skills

# Copy skills & scripts
cp -r scripts/* ~/.openclaw/scripts/
cp -r skills/* ~/.openclaw/skills/

# Copy config templates
cp openclaw.json.example ~/.openclaw/openclaw.json
cp access-whitelist.example.json ~/.openclaw/access-whitelist.json
```

### 5. Start the Daemon
```bash
openclaw daemon start
```

---

## 🧠 All Skills (The "MightyRaju" Suite)

This setup comes with **15+ skills** ready to use.

### Custom Skills (Built for this Repo)
| Skill | Command / Trigger | What it does |
|---|---|---|
| **📊 System Monitor** | "System status", "Health check" | Checks CPU load, free RAM, disk space, and uptime. |
| **🌅 Daily Briefing** | "Good morning", "Briefing" | Shows date, weather, system health, and top 5 todo tasks. |
| **📝 Notes** | "Add a note...", "Show notes" | Appends to `~/.openclaw/notes.txt`. A simple second brain. |
| **🎗️ Reminder** | "Remind me to...", "Show todo" | Manages a simple todo list in `~/.openclaw/todo.txt`. |
| **🧮 Calculator** | "Calculate 5 * 12" | Uses `bc` for math. |
| **🌐 Network Tools** | "What is my IP?", "Ping Google" | Checks connectivity & public IP. |
| **🔐 Access Control** | `/add_access <id>`, `/list_access` | **Owner-only** commands to manage Telegram access. |

### Built-in Skills (Enabled)
| Skill | Description |
|---|---|
| **🌤️ Weather** | Forecasts via `wttr.in`. |
| **📦 GitHub** | Manage issues and repositories. |
| **📦 Healthcheck** | OpenClaw internal diagnostics. |
| **📜 Session Logs** | **Search your past conversations** using `ripgrep`. |
| **🧵 Tmux** | Remote control terminal sessions. |
| **🎞️ Video Frames** | Extract images from video files. |
| **📦 Skill Creator** | Ask the AI to write new skills for itself! |

---

## 🛡️ Security Hardening

This setup is designed for **maximum security**:

- **Whitelist Only**: The bot ignores messages from strangers.
- **Local Binding**: The Gateway listens on `127.0.0.1` by default.
- **Sanitized Config**: Secrets are never checked into git (thanks to `.gitignore`).

To add a friend/family member:
1. Ask them to chat with the bot.
   - They will receive a message: `Access not configured. Please ask the owner to approve pairing code: 123456`.
2. You (the owner) run: `/add_access 123456 "Friend Name"` in your Telegram chat with the bot.
   - This approves their pairing code AND adds them to the whitelist in one step.

---

## 🤝 Contributing

Feel free to fork this repo and add your own skills! Skills are just markdown files with simple bash scripts embedded in them.

## 📄 License

MIT
