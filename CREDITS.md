# Credits & Sources

This project is built on the shoulders of others. All components are open-source.

## Core Dependencies

| Project | Author | Link | What it provides |
|---|---|---|---|
| Pi | earendil-works | https://github.com/earendil-works/pi | Open-source AI agent CLI |
| pi-obsidian-vault | itscool2b | https://www.npmjs.com/package/pi-obsidian-vault | Vault read/write tools for Pi |
| obsidian-pi-plugin | sigilmakes | https://github.com/sigilmakes/obsidian-pi-plugin | Pi chat UI inside Obsidian |
| obsidian-git-sync-skill | alexliu072903-bit | https://github.com/alexliu072903-bit/obsidian-git-sync-skill | Vault → GitHub sync |

## Patches & Contributions

**Windows `spawn EINVAL` fix** (`obsidian-pi-plugin/src/rpc.ts`)
The original plugin used `child_process.spawn()` without `shell: true`, which fails on Windows when targeting `.cmd` files. This project adds `shell: process.platform === "win32"` to the spawn options. A PR has been submitted upstream.

## License

All referenced projects use MIT or compatible licenses. This project is also MIT licensed.
