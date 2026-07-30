#!/usr/bin/env bash

set -Eeuo pipefail

PI_VERSION="0.82.1"
VAULT_PACKAGE_VERSION="0.2.3"
PLUGIN_REF="3ccd701160009d256528ee7794e80ee95b380a74"
PLUGIN_REPOSITORY="https://github.com/sigilmakes/obsidian-pi-plugin.git"
MIN_NODE_VERSION="22.19.0"

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
ROOT_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
PATCH_FILE="$ROOT_DIR/patches/obsidian-pi-plugin-cross-platform.patch"

VAULT_PATH=""
GITHUB_URL=""
PUSH_TO_GITHUB="false"
BUILD_ROOT=""

log() {
  printf '  %s\n' "$1"
}

ok() {
  printf '  OK  %s\n' "$1"
}

die() {
  printf '  ERR %s\n' "$1" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Obsidian AI Starter — macOS setup

Usage:
  ./scripts/setup.sh --vault "/absolute/path/to/vault"

Optional private GitHub backup:
  ./scripts/setup.sh \
    --vault "/absolute/path/to/vault" \
    --github-url "https://github.com/username/private-vault.git" \
    --push

Options:
  --vault PATH         Absolute path to an existing Obsidian vault
  --github-url URL     Empty private GitHub repository for the initial backup
  --push               Preview, confirm, then push the vault to GitHub
  -h, --help           Show this help
EOF
}

cleanup() {
  if [[ -n "$BUILD_ROOT" && -d "$BUILD_ROOT" ]]; then
    rm -rf -- "$BUILD_ROOT"
  fi
}

trap cleanup EXIT

version_at_least() {
  local actual="$1"
  local required="$2"
  local actual_major actual_minor actual_patch
  local required_major required_minor required_patch

  IFS=. read -r actual_major actual_minor actual_patch <<<"$actual"
  IFS=. read -r required_major required_minor required_patch <<<"$required"

  ((actual_major > required_major)) ||
    ((actual_major == required_major && actual_minor > required_minor)) ||
    ((actual_major == required_major && actual_minor == required_minor && actual_patch >= required_patch))
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "$1 is not installed or not available on PATH."
}

configure_plugin_data() {
  local data_path="$1"
  local pi_binary="$2"

  PI_DATA_PATH="$data_path" PI_BINARY_PATH="$pi_binary" node <<'NODE'
const fs = require("node:fs");

const path = process.env.PI_DATA_PATH;
const piBinaryPath = process.env.PI_BINARY_PATH;
let data = {};

if (fs.existsSync(path)) {
  try {
    data = JSON.parse(fs.readFileSync(path, "utf8"));
  } catch (error) {
    throw new Error(`Cannot parse existing plugin settings at ${path}: ${error.message}`);
  }
}

data.piBinaryPath = piBinaryPath;
data.workingDirectory ??= "";
data.defaultProvider ??= "";
data.defaultModel ??= "";
data.sessionSaveDir ??= "Pi-Sessions";
data.persistSessions ??= true;
data.thinkingLevel ??= "medium";

fs.writeFileSync(path, `${JSON.stringify(data, null, 2)}\n`, "utf8");
NODE
}

write_gitignore_if_missing() {
  local gitignore_path="$VAULT_PATH/.gitignore"

  if [[ -e "$gitignore_path" ]]; then
    ok "Existing .gitignore preserved"
    return
  fi

  cat >"$gitignore_path" <<'EOF'
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/plugins/*/data.json
.trash/
.DS_Store
EOF
  ok "Created a conservative Obsidian .gitignore"
}

push_private_backup() {
  if [[ "$PUSH_TO_GITHUB" != "true" ]]; then
    return 0
  fi
  [[ -n "$GITHUB_URL" ]] || die "--push requires --github-url."

  printf '\n'
  log "Preparing an optional GitHub backup."
  log "Use an empty PRIVATE repository. This script cannot verify repository visibility."

  if [[ ! -d "$VAULT_PATH/.git" ]]; then
    git -C "$VAULT_PATH" init
    git -C "$VAULT_PATH" branch -M main
    ok "Initialized Git in the vault"
  fi

  if ! git -C "$VAULT_PATH" diff --cached --quiet; then
    die "The vault already has staged Git changes. Commit or unstage them before using --push."
  fi

  write_gitignore_if_missing

  local current_origin
  current_origin="$(git -C "$VAULT_PATH" remote get-url origin 2>/dev/null || true)"
  if [[ -n "$current_origin" && "$current_origin" != "$GITHUB_URL" ]]; then
    die "Existing origin does not match --github-url. Refusing to push to an unexpected repository."
  fi
  if [[ -z "$current_origin" ]]; then
    git -C "$VAULT_PATH" remote add origin "$GITHUB_URL"
  fi

  local remote_refs
  if ! remote_refs="$(git -C "$VAULT_PATH" ls-remote origin 2>/dev/null)"; then
    die "Cannot access the GitHub repository. Check the URL and Git authentication."
  fi
  [[ -z "$remote_refs" ]] || die "The GitHub repository is not empty. Refusing to overwrite or merge automatically."

  git -C "$VAULT_PATH" add .
  printf '\nFiles staged for the initial backup:\n'
  git -C "$VAULT_PATH" status --short
  printf '\nPush these files to %s? Type "push" to continue: ' "$GITHUB_URL"

  local confirmation
  read -r confirmation
  if [[ "$confirmation" != "push" ]]; then
    git -C "$VAULT_PATH" reset --quiet
    die "GitHub backup cancelled. No files were pushed."
  fi

  if git -C "$VAULT_PATH" diff --cached --quiet; then
    ok "No new vault files to commit"
  else
    git -C "$VAULT_PATH" commit -m "Initial private Obsidian vault backup"
  fi

  git -C "$VAULT_PATH" branch -M main
  git -C "$VAULT_PATH" push -u origin main
  ok "Vault pushed to GitHub"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --vault)
      [[ $# -ge 2 ]] || die "--vault requires a path."
      VAULT_PATH="$2"
      shift 2
      ;;
    --github-url)
      [[ $# -ge 2 ]] || die "--github-url requires a URL."
      GITHUB_URL="$2"
      shift 2
      ;;
    --push)
      PUSH_TO_GITHUB="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
done

printf '\nObsidian AI Starter — macOS setup\n\n'

[[ "$(uname -s)" == "Darwin" ]] || die "This script supports macOS only. Use scripts/setup.ps1 on Windows."
[[ -n "$VAULT_PATH" ]] || die "--vault is required. Run with --help for usage."
[[ -d "$VAULT_PATH" ]] || die "Vault path not found: $VAULT_PATH"
[[ -d "$VAULT_PATH/.obsidian" ]] || die "The selected folder is not an Obsidian vault: .obsidian is missing."
VAULT_PATH="$(CDPATH= cd -- "$VAULT_PATH" && pwd -P)"
ok "Vault verified: $VAULT_PATH"

require_command node
require_command npm
require_command git

NODE_VERSION="$(node -p 'process.versions.node')"
version_at_least "$NODE_VERSION" "$MIN_NODE_VERSION" ||
  die "Node.js $MIN_NODE_VERSION or newer is required. Found $NODE_VERSION."
ok "Node.js $NODE_VERSION"

log "Installing Pi $PI_VERSION..."
npm install -g --ignore-scripts "@earendil-works/pi-coding-agent@$PI_VERSION"
PI_BINARY="$(command -v pi)"
[[ -x "$PI_BINARY" ]] || die "Pi installed but no executable was found on PATH."
ok "Pi installed at $PI_BINARY"

log "Installing pi-obsidian-vault $VAULT_PACKAGE_VERSION..."
pi install "npm:pi-obsidian-vault@$VAULT_PACKAGE_VERSION"
ok "Vault tools installed"

[[ -f "$PATCH_FILE" ]] || die "Required patch not found: $PATCH_FILE"
BUILD_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/obsidian-ai-starter.XXXXXX")"
PLUGIN_DIR="$BUILD_ROOT/obsidian-pi-plugin"

log "Fetching the pinned Obsidian Pi plugin..."
git init "$PLUGIN_DIR" >/dev/null
git -C "$PLUGIN_DIR" remote add origin "$PLUGIN_REPOSITORY"
git -C "$PLUGIN_DIR" fetch --depth 1 origin "$PLUGIN_REF"
git -C "$PLUGIN_DIR" checkout --detach FETCH_HEAD >/dev/null
git -C "$PLUGIN_DIR" apply "$PATCH_FILE"
ok "Plugin source prepared"

log "Building the Obsidian plugin..."
npm --prefix "$PLUGIN_DIR" ci --ignore-scripts
npm --prefix "$PLUGIN_DIR" run build
ok "Plugin built"

DEST_DIR="$VAULT_PATH/.obsidian/plugins/pi-plugin"
mkdir -p "$DEST_DIR"
cp "$PLUGIN_DIR/main.js" "$DEST_DIR/main.js"
cp "$PLUGIN_DIR/styles.css" "$DEST_DIR/styles.css"
cp "$PLUGIN_DIR/manifest.json" "$DEST_DIR/manifest.json"
configure_plugin_data "$DEST_DIR/data.json" "$PI_BINARY"
ok "Plugin installed in the vault"

push_private_backup

printf '\nSetup complete.\n'
printf 'Next: open README.md or README.zh.md and finish the steps under "Finish in Obsidian".\n'
