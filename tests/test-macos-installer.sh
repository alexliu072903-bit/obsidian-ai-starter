#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/obsidian-ai-starter-test.XXXXXX")"
FAKE_BIN="$TEST_ROOT/bin"
FAKE_VAULT="$TEST_ROOT/My Vault"

cleanup() {
  rm -rf -- "$TEST_ROOT"
}

trap cleanup EXIT

mkdir -p "$FAKE_BIN" "$FAKE_VAULT/.obsidian"

cat >"$FAKE_BIN/node" <<'EOF'
#!/usr/bin/env bash
set -e
if [[ "${1:-}" == "-p" ]]; then
  printf '22.19.0\n'
  exit 0
fi
cat >/dev/null
printf '{}\n' >"$PI_DATA_PATH"
EOF

cat >"$FAKE_BIN/npm" <<'EOF'
#!/usr/bin/env bash
set -e
prefix=""
previous=""
for argument in "$@"; do
  if [[ "$previous" == "--prefix" ]]; then
    prefix="$argument"
  fi
  previous="$argument"
done
if [[ "$*" == *" run build"* ]]; then
  printf 'plugin\n' >"$prefix/main.js"
  printf 'styles\n' >"$prefix/styles.css"
  printf '{"id":"pi-plugin"}\n' >"$prefix/manifest.json"
fi
EOF

cat >"$FAKE_BIN/pi" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF

cat >"$FAKE_BIN/git" <<'EOF'
#!/usr/bin/env bash
set -e
if [[ "${1:-}" == "init" ]]; then
  mkdir -p "$2"
fi
exit 0
EOF

chmod +x "$FAKE_BIN/node" "$FAKE_BIN/npm" "$FAKE_BIN/pi" "$FAKE_BIN/git"

PATH="$FAKE_BIN:/usr/bin:/bin" \
  "$ROOT_DIR/scripts/setup.sh" --vault "$FAKE_VAULT"

PLUGIN_DIR="$FAKE_VAULT/.obsidian/plugins/pi-plugin"
for file in main.js styles.css manifest.json data.json; do
  [[ -f "$PLUGIN_DIR/$file" ]] || {
    printf 'Missing installer output: %s\n' "$file" >&2
    exit 1
  }
done

printf 'macOS installer smoke test passed\n'
