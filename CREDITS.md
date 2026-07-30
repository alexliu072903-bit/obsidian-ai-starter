# Credits and Sources

Obsidian AI Starter integrates existing open-source projects. It does not claim ownership of them.

| Project | Maintainer | Role | Pinned version/ref |
|---|---|---|---|
| [Pi](https://github.com/earendil-works/pi) | Earendil Inc. and contributors | Local coding-agent runtime | `0.82.1` |
| [pi-obsidian-vault](https://pi.dev/packages/pi-obsidian-vault) | itscool2b | Bounded Obsidian vault tools | `0.2.3` |
| [obsidian-pi-plugin](https://github.com/sigilmakes/obsidian-pi-plugin) | sigilmakes | Obsidian chat interface | `3ccd701160009d256528ee7794e80ee95b380a74` |

## Local compatibility patch

`patches/obsidian-pi-plugin-cross-platform.patch` contains two small integration fixes:

- use `shell: true` only on Windows so Node.js can launch `pi.cmd`;
- replace a machine-specific default Pi path with `pi`.

The original source remains in the upstream repository. The installer fetches the pinned upstream commit and applies the patch during the local build.

## License

This integration repository is MIT licensed. Upstream projects retain their own copyright and license terms.
