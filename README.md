# Obsidian AI Starter

**English** | [中文](README.zh-CN.md)

A small, reproducible setup that brings the Pi coding agent into an existing Obsidian vault on Windows or macOS.

It gives you:

- an AI chat panel inside Obsidian;
- bounded Obsidian vault tools through `pi-obsidian-vault`;
- Markdown copies of conversations in `Pi-Sessions/`;
- your choice of Pi-supported model provider, using your own account or API key.

This repository is an installer and integration layer. It does not fork Pi or the Obsidian plugin.

## Platform support

| Platform | Installer | Status |
|---|---|---|
| Windows 10/11 | `scripts/setup.ps1` | Supported |
| macOS | `scripts/setup.sh` | Supported |
| Linux | — | Not currently supported |
| Obsidian mobile | — | Not supported |

## Prerequisites

- Obsidian Desktop and an existing vault
- Node.js `>= 22.19.0`
- npm
- Git
- Windows only: Git for Windows, which provides the bash shell required by Pi
- a Pi-supported subscription or API key

The installers never ask for or store your API key.

## Install

Clone this repository, then run the installer for your platform.

### macOS

```bash
git clone https://github.com/alexliu072903-bit/obsidian-ai-starter.git
cd obsidian-ai-starter
chmod +x scripts/setup.sh
./scripts/setup.sh --vault "/absolute/path/to/your/Obsidian Vault"
```

### Windows

```powershell
git clone https://github.com/alexliu072903-bit/obsidian-ai-starter.git
cd obsidian-ai-starter
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\setup.ps1 -VaultPath "D:\path\to\your\Obsidian Vault"
```

The installer:

1. verifies the selected folder is an Obsidian vault;
2. verifies Node.js, npm, Git, and the platform requirements;
3. installs a pinned Pi release and `pi-obsidian-vault`;
4. fetches a pinned `obsidian-pi-plugin` commit;
5. applies the cross-platform compatibility patch and builds the plugin;
6. copies the plugin into `.obsidian/plugins/pi-plugin/`;
7. records the absolute Pi binary path without deleting existing plugin data.

Any failed native command stops the installer. Temporary build files are isolated and removed when the script exits.

## Finish in Obsidian

1. Open the vault in Obsidian Desktop.
2. Go to **Settings → Community plugins** and enable community plugins.
3. Enable the **Pi** plugin.
4. Go to **Settings → General → Advanced → Command line interface**, enable it, then choose **Register for PATH**.
5. Open a terminal, run `pi`, then use `/login` to select a subscription or API-key provider.
6. In Obsidian, open the command palette and run **Pi: Open chat**.

Test the integration:

```text
Find my notes about <topic> and summarize the relevant context.
```

If Pi cannot find the vault, run this inside Pi:

```text
/obsidian-vault set-vault /absolute/path/to/your/Obsidian Vault
```

## Optional private GitHub backup

GitHub backup is disabled by default. Only use an empty **private** repository.

### macOS

```bash
./scripts/setup.sh \
  --vault "/absolute/path/to/your/Obsidian Vault" \
  --github-url "https://github.com/username/private-vault.git" \
  --push
```

### Windows

```powershell
.\scripts\setup.ps1 `
  -VaultPath "D:\path\to\your\Obsidian Vault" `
  -GitHubUrl "https://github.com/username/private-vault.git" `
  -PushToGitHub
```

Before pushing, the installer:

- refuses a non-empty remote;
- refuses to replace an existing mismatched `origin`;
- prints every staged file;
- requires you to type `push`.

The installer cannot verify whether a GitHub repository is private. Confirm that yourself before approving the push.

## Security boundary

Pi is a local coding agent, not a vault sandbox. It runs with the filesystem, shell, network, and credential permissions of your user account. The working directory is the vault, but that does not prevent Pi from accessing other paths available to your account.

Review requests before allowing changes, keep private notes out of public repositories, and use a container or VM if you need a real isolation boundary.

See the official [Pi security documentation](https://pi.dev/docs/latest/security).

## Pinned components

| Component | Version/ref |
|---|---|
| `@earendil-works/pi-coding-agent` | `0.82.1` |
| `pi-obsidian-vault` | `0.2.3` |
| `sigilmakes/obsidian-pi-plugin` | `3ccd701160009d256528ee7794e80ee95b380a74` |

Pinning keeps installations reproducible. Version changes should be tested on Windows and macOS before these values are updated.

## License

MIT
