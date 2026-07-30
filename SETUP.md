# Setup Guide for AI Agents

Use this file when a user pastes the repository into Claude Code, Codex, or another coding agent.

## Objective

Install Obsidian AI Starter into one existing Obsidian Desktop vault on Windows or macOS.

## Required input

Ask for only:

1. the absolute path to the Obsidian vault;
2. whether the user wants the optional initial GitHub backup.

If backup is requested, also ask for the URL of an empty private GitHub repository.

Never ask the user to paste an API key into the conversation or installer.

## Run the platform installer

### macOS

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh --vault "/absolute/path/to/vault"
```

Optional private backup:

```bash
./scripts/setup.sh \
  --vault "/absolute/path/to/vault" \
  --github-url "https://github.com/username/private-vault.git" \
  --push
```

### Windows

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\setup.ps1 -VaultPath "D:\path\to\vault"
```

Optional private backup:

```powershell
.\scripts\setup.ps1 `
  -VaultPath "D:\path\to\vault" `
  -GitHubUrl "https://github.com/username/private-vault.git" `
  -PushToGitHub
```

Do not bypass a failed prerequisite, vault validation, mismatched Git remote, non-empty remote, failed patch, failed build, or failed native command.

## Manual steps after installation

Tell the user to:

1. open the vault in Obsidian Desktop;
2. enable community plugins;
3. enable the Pi plugin;
4. enable Obsidian CLI and choose **Register for PATH**;
5. run `pi` in a terminal and use `/login`;
6. run **Pi: Open chat** from the Obsidian command palette.

If vault auto-detection fails:

```text
/obsidian-vault set-vault /absolute/path/to/vault
```

## Verification

Ask Pi:

```text
Find my notes about <known topic> and list the relevant files.
```

Success means:

- the Pi chat opens inside Obsidian;
- the model responds;
- the vault query returns bounded, relevant results;
- closing or saving the conversation creates a Markdown file under `Pi-Sessions/`.

## Security constraints

- Pi has the permissions of the local user account; the vault working directory is not a sandbox.
- The installer must never request or log an API key.
- GitHub backup is opt-in and requires an explicit file preview plus confirmation.
- The installer cannot verify repository visibility; the user must confirm the repository is private.
- Do not weaken these checks to make an installation appear successful.
