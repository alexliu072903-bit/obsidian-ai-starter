# Obsidian AI Starter

[English](README.md) | **中文**

一套可复现的安装方案，让 Pi coding agent 在 Windows 或 macOS 的现有 Obsidian vault 中运行。

它提供：

- Obsidian 内的 AI 对话面板；
- 通过 `pi-obsidian-vault` 获取受约束的 vault 工具；
- 自动把对话保存到 `Pi-Sessions/`，成为 Markdown 笔记；
- 使用你自己的账号或 API Key，选择 Pi 已支持的模型供应商。

这个仓库是安装与集成层，不是 Pi 或 Obsidian 插件的 fork。

## 平台支持

| 平台 | 安装脚本 | 状态 |
|---|---|---|
| Windows 10/11 | `scripts/setup.ps1` | 支持 |
| macOS | `scripts/setup.sh` | 支持 |
| Linux | — | 暂不支持 |
| Obsidian 移动端 | — | 不支持 |

## 前置条件

- Obsidian Desktop 和一个已有的 vault
- Node.js `>= 22.19.0`
- npm
- Git
- 仅 Windows：Git for Windows，Pi 需要它提供 bash shell
- 一个 Pi 支持的订阅账号或 API Key

安装脚本不会要求、读取或保存你的 API Key。

## 安装

先克隆仓库，再运行对应平台的安装脚本。

### macOS

```bash
git clone https://github.com/alexliu072903-bit/obsidian-ai-starter.git
cd obsidian-ai-starter
chmod +x scripts/setup.sh
./scripts/setup.sh --vault "/你的/Obsidian Vault/绝对路径"
```

### Windows

```powershell
git clone https://github.com/alexliu072903-bit/obsidian-ai-starter.git
cd obsidian-ai-starter
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\setup.ps1 -VaultPath "D:\你的\Obsidian Vault"
```

安装脚本会：

1. 确认目标目录确实是 Obsidian vault；
2. 检查 Node.js、npm、Git 和平台依赖；
3. 安装固定版本的 Pi 与 `pi-obsidian-vault`；
4. 获取固定 commit 的 `obsidian-pi-plugin`；
5. 应用跨平台兼容补丁并构建插件；
6. 把插件复制到 `.obsidian/plugins/pi-plugin/`；
7. 写入 Pi 的绝对路径，同时保留已有插件数据。

任意原生命令失败都会立即终止安装。临时构建目录相互隔离，并会在脚本退出时删除。

## 在 Obsidian 内完成配置

1. 使用 Obsidian Desktop 打开该 vault。
2. 进入 **设置 → 第三方插件**，开启第三方插件。
3. 启用 **Pi** 插件。
4. 进入 **设置 → 常规 → 高级 → 命令行界面**，启用后点击 **Register for PATH**。
5. 打开终端，运行 `pi`，然后使用 `/login` 选择订阅账号或 API Key 供应商。
6. 回到 Obsidian，打开命令面板，执行 **Pi: Open chat**。

验证：

```text
查找我关于 <主题> 的笔记，并总结相关上下文。
```

如果 Pi 没有识别出 vault，在 Pi 中运行：

```text
/obsidian-vault set-vault /你的/Obsidian Vault/绝对路径
```

## 可选：备份到私人 GitHub 仓库

GitHub 备份默认关闭，只能使用空的 **private repository**。

### macOS

```bash
./scripts/setup.sh \
  --vault "/你的/Obsidian Vault/绝对路径" \
  --github-url "https://github.com/username/private-vault.git" \
  --push
```

### Windows

```powershell
.\scripts\setup.ps1 `
  -VaultPath "D:\你的\Obsidian Vault" `
  -GitHubUrl "https://github.com/username/private-vault.git" `
  -PushToGitHub
```

上传前，脚本会：

- 拒绝非空远程仓库；
- 拒绝替换地址不一致的已有 `origin`；
- 展示所有待提交文件；
- 要求你手动输入 `push`。

脚本无法判断 GitHub 仓库是否为 private。确认无误后再批准上传。

## 安全边界

Pi 是本地 coding agent，不是 vault sandbox。它拥有当前系统用户的文件、Shell、网络和凭证权限。工作目录设为 vault，并不代表 Pi 无法访问该账号有权限访问的其他路径。

确认请求内容后再允许修改；不要把私人笔记上传到公开仓库；需要真正隔离时，使用 container 或 VM。

详见 [Pi 官方安全文档](https://pi.dev/docs/latest/security)。

## 固定依赖版本

| 组件 | 版本/ref |
|---|---|
| `@earendil-works/pi-coding-agent` | `0.82.1` |
| `pi-obsidian-vault` | `0.2.3` |
| `sigilmakes/obsidian-pi-plugin` | `3ccd701160009d256528ee7794e80ee95b380a74` |

固定版本用于保证安装结果可复现。升级这些值前，需要同时验证 Windows 和 macOS。

## License

MIT
