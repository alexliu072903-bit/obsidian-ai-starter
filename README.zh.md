# Obsidian AI Starter

> 一次配置，三个超能力 —— 把 Obsidian 变成你自己的 AI 工作台。

[English](README.md) | **中文**

---

## 这是什么

Obsidian AI Starter 是一套开箱即用的自动化配置方案，让 [Pi](https://github.com/earendil-works/pi)（开源 AI agent）直接在你的 Obsidian 笔记库内运行。用你自己的 API Key，按量计费，不锁定任何厂商，对话自动保存为笔记，并拥有完整的 agent 能力。

简单来说：**Claudian 的平价替代，成本只花十分之一。**

## 你会得到什么

### 1. 接管你笔记库的 AI

Pi 在 Obsidian 内部运行，能直接读写你的笔记。接入 DeepSeek、GPT-4o 或任意 LLM 的 API Key，按量计费，随时切换模型，不受厂商锁定。换模型不需要动 vault 结构，换个 Key 就行。

### 2. 对话即笔记

每段 Pi 对话结束后，自动保存到 vault 的 `Pi-Sessions/` 文件夹，成为可搜索的 Markdown 文件。你和 AI 的思考过程，本身就是知识库的一部分 —— 版本化、可检索、可链接。

### 3. 完整 Agent，不只是聊天框

| 命令 | 能力 | 说明 |
|---|---|---|
| `/plan` | 先规划再动手 | 复杂任务先拆解成步骤，确认后再执行 |
| `/loop` | 自动迭代 | 反复执行直到达成目标，无需人工干预 |
| `/swarm` | 多 agent 并行 | 拆成子任务，多个 agent 同时处理 |

这些是 Claudian 等纯聊天插件做不到的。

## 快速开始

### 前置条件

- Obsidian Desktop
- Node.js + npm
- Git
- 一个 LLM API Key（推荐 [DeepSeek](https://platform.deepseek.com/)，成本最低；也支持 OpenAI / Anthropic）

### 安装

1. **克隆本仓库**

   ```bash
   git clone https://github.com/alexliu072903-bit/obsidian-ai-starter.git
   cd obsidian-ai-starter
   ```

2. **运行安装脚本**

   把 [SETUP.md](SETUP.md) 粘贴给 Claude Code 或 Codex，AI 会自动执行脚本并告诉你剩余的手动步骤。

   也可以直接运行：

   ```powershell
   .\scripts\setup.ps1 -VaultPath "D:\ob\Obsidian Vault" -GitHubUrl "https://github.com/username/my-vault.git"
   ```

3. **在 Obsidian 中完成 5 个手动步骤**（约 5 分钟）

   详见 [SETUP.md](SETUP.md) 的「Manual Steps」部分。

### 验证

打开 Obsidian 命令面板（`Ctrl+P`）→ 搜索 **Pi: Open chat** → 输入 `hi` → Pi 应该会回复。

测试 vault 访问：
```
Read my vault and give me a summary of what's in it
```

## 安装脚本做了什么

`scripts/setup.ps1` 会自动完成以下操作：

- ✅ 全局安装 Pi CLI（`@mariozechner/pi-coding-agent`）
- ✅ 安装 `pi-obsidian-vault`（赋予 Pi 读写 vault 的能力）
- ✅ 克隆 `obsidian-pi-plugin`，应用 Windows 兼容性补丁，构建插件
- ✅ 将插件文件复制到 vault 的 `.obsidian/plugins/pi-plugin/` 目录
- ✅ 在 vault 中初始化 Git，创建 `.gitignore`，连接 GitHub 远程仓库并推送

Obsidian 的插件系统需要在应用内点击操作，无法从外部自动化 —— 这部分需要手动完成。

## 平台支持

| 平台 | 状态 |
|---|---|
| Windows | ✅ 已支持（包含 spawn 兼容性修复） |
| macOS / Linux | ⚠️ 理论可用，未经测试 |

## 致谢

本项目基于以下开源项目构建，详见 [CREDITS.md](CREDITS.md)：

| 项目 | 作者 | 作用 |
|---|---|---|
| [Pi](https://github.com/earendil-works/pi) | earendil-works | 开源 AI agent CLI |
| [pi-obsidian-vault](https://www.npmjs.com/package/pi-obsidian-vault) | itscool2b | Vault 读写工具 |
| [obsidian-pi-plugin](https://github.com/sigilmakes/obsidian-pi-plugin) | sigilmakes | Obsidian 内 Pi 聊天 UI |
| [obsidian-git-sync-skill](https://github.com/alexliu072903-bit/obsidian-git-sync-skill) | alexliu072903-bit | Vault → GitHub 自动同步 |

## License

MIT
