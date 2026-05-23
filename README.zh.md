# Obsidian AI Starter

> 一次配置，三个超能力。

用你自己的 API Key，把 Obsidian 变成真正的 AI 工作台。

## 你会得到什么

**1. 接管你笔记库的 AI，价格只有 Claudian 的零头**
Pi 在 Obsidian 内部运行，能直接读写你的笔记。接上 DeepSeek、GPT-4o 或任何 LLM 的 API Key，按量计费，随时换模型，不锁定任何厂商。

**2. 每次 AI 对话都自动变成笔记**
每段 Pi 对话结束后，自动保存到 vault 的 `Pi-Sessions/` 文件夹，成为可搜索的 Markdown 文件。你和 AI 的思考过程，本身就是知识库的一部分。

**3. 完整 agent，不只是聊天框**
`/plan` 先规划再动手，`/loop` 自动迭代直到完成，`/swarm` 多个 agent 并行处理复杂任务。这些是 Claudian 没有的能力。

## 快速开始

→ 把 [SETUP.md](SETUP.md) 粘贴给 Claude Code 或 Codex，自动化部分会自动搞定。Obsidian 内的手动步骤大约 5 分钟。

**前置条件**
- Obsidian Desktop
- Node.js + npm
- Git
- API Key（推荐 DeepSeek，价格最低；也支持 OpenAI / Anthropic）

## 平台支持

| 平台 | 状态 |
|---|---|
| Windows | 支持（已包含 spawn 兼容性修复） |
| macOS / Linux | 理论可用，未经测试 |

## 致谢

本项目基于多个开源项目，详见 [CREDITS.md](CREDITS.md)。

## License

MIT
