# Setup Guide

This file is designed to be pasted into Claude Code or Codex.
The agent will run the automated parts and tell you exactly which manual steps remain.

---

## Instructions for the AI agent

You are helping a user set up the Obsidian AI Starter on Windows.

Ask the user for the following before running anything:
1. **Vault path** — the absolute path to their Obsidian vault (e.g. `D:\ob\Obsidian Vault`)
2. **GitHub repo URL** — an empty GitHub repo they created for vault backup (e.g. `https://github.com/username/my-vault.git`)
3. **API key provider** — which LLM provider they're using (deepseek / openai / anthropic)

Then run `scripts/setup.ps1` with the vault path:

```powershell
.\scripts\setup.ps1 -VaultPath "D:\ob\Obsidian Vault" -GitHubUrl "https://github.com/username/my-vault.git"
```

After the script completes successfully, tell the user to do the following **5 manual steps** inside Obsidian.

---

## Manual Steps (do these in Obsidian after the script runs)

### Step 1 — Enable Community Plugins
Obsidian → Settings → Third-party plugins → Turn off Safe mode

### Step 2 — Enable Obsidian CLI
Obsidian → Settings → General → scroll to the bottom → Advanced → CLI (Command line interface) → check Enable → click **Register for PATH**

### Step 3 — Enable the Pi Plugin
Obsidian → Settings → Third-party plugins → find **Pi** in the list → toggle it on

### Step 4 — Configure Pi Plugin
Click the gear icon next to Pi:
- **Pi binary path**: `C:\Users\<YourUsername>\AppData\Roaming\npm\pi.cmd`
  (Replace `<YourUsername>` with your Windows username)
- **Working directory**: your vault path (e.g. `D:\ob\Obsidian Vault`)
- **Default provider**: your LLM provider (e.g. `deepseek`)

### Step 5 — Set your API key
In the Pi terminal (or any terminal), run:
```
pi /config set-key
```
Follow the prompt to enter your API key.

---

## Verify it works

Open Obsidian command palette (`Ctrl+P`) → search **Pi: Open chat** → type `hi` → Pi should respond.

To test vault access, ask Pi:
```
Read my vault and give me a summary of what's in it
```

---

## What the script does (automated)

- Installs Pi CLI globally (`@mariozechner/pi-coding-agent`)
- Installs `pi-obsidian-vault` (gives Pi read/write access to your vault)
- Clones `obsidian-pi-plugin`, applies the Windows compatibility patch, builds it
- Copies the plugin files to your vault's `.obsidian/plugins/pi-plugin/` directory
- Initializes git in your vault and connects it to your GitHub repo

## What stays manual

Obsidian's plugin system requires clicks in the UI — it cannot be automated from outside the app.
