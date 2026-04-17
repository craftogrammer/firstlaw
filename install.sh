#!/usr/bin/env sh
# firstlaw installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/install.sh | sh
#   curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/install.sh | sh -s -- --force
#
# Installs:
#   CONSTITUTION.md         at repo root
#   .law/                   at repo root
#   KIT_VERSION             at repo root
#
# Idempotent: will not overwrite existing files unless --force is passed.
# After install, open a new chat with any agent and say: "read CONSTITUTION.md"

set -eu

# ---------- configuration ----------

# EDIT THIS to the raw base URL of your kit repo before publishing.
KIT_BASE_URL="${KIT_BASE_URL:-https://raw.githubusercontent.com/craftogrammer/firstlaw/main}"

FORCE=0
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    --help|-h)
      sed -n '2,15p' "$0"
      exit 0
      ;;
  esac
done

# ---------- utilities ----------

log()  { printf '%s\n' "$*" >&2; }
die()  { log "install.sh: $*"; exit 1; }

need() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

need curl
need mkdir

fetch() {
  # fetch <url> <dest>
  _url="$1"; _dest="$2"
  _dir="$(dirname "$_dest")"
  [ -d "$_dir" ] || mkdir -p "$_dir"
  if [ -e "$_dest" ] && [ "$FORCE" -ne 1 ]; then
    log "skip (exists): $_dest"
    return 0
  fi
  curl -fsSL "$_url" -o "$_dest" || die "download failed: $_url"
  case "$_dest" in
    ./.law/bin/*|./.law/git-hooks/*|./.law/templates/*) chmod +x "$_dest" 2>/dev/null || true ;;
  esac
  log "wrote: $_dest"
}

# ---------- file manifest ----------
# Kept flat and explicit. No globbing; the installer pulls exactly these files.

FILES="
CONSTITUTION.md
KIT_VERSION
.law/KIT_INDEX.md
.law/adapters.md
.law/bootstrap/INIT.md
.law/bootstrap/questions/cross-cutting.json
.law/subagents/README.md
.law/subagents/product.contract.md
.law/subagents/architecture.contract.md
.law/subagents/ownership.contract.md
.law/subagents/ambiguity.contract.md
.law/subagents/doc-taxonomy.contract.md
.law/subagents/adapter.contract.md
.law/subagents/quality-audit.contract.md
.law/contracts/project.contract.json
.law/contracts/domain-map.contract.json
.law/contracts/truth-owners.contract.json
.law/contracts/dependency-rules.contract.json
.law/contracts/ambiguity-policies.contract.json
.law/contracts/doc-taxonomy.contract.json
.law/contracts/quality-audit.contract.json
.law/schemas/project.schema.json
.law/schemas/domain-map.schema.json
.law/schemas/truth-owners.schema.json
.law/schemas/dependency-rules.schema.json
.law/schemas/ambiguity-policies.schema.json
.law/schemas/doc-taxonomy.schema.json
.law/schemas/quality-audit.schema.json
.law/schemas/subagent-envelope.schema.json
.law/doctrine/product.md
.law/doctrine/architecture.md
.law/doctrine/agent-behavior.md
.law/charters/README.md
.law/charters/example-domain.md
.law/context/current-system.json
.law/context/pending-questions.json
.law/context/research/README.md
.law/bin/README.md
.law/bin/verify-adapters
.law/bin/validate-contracts
.law/bin/check-coupling
.law/git-hooks/pre-commit.sample
.law/templates/README.md
.law/templates/check-truth-owners.example.mjs
.law/templates/check-dep-direction.example.mjs
.law/templates/check-anti-patterns.example.mjs
"

# ---------- preflight ----------

if [ -f CONSTITUTION.md ] && [ "$FORCE" -ne 1 ]; then
  log "note: CONSTITUTION.md already exists. Re-run with --force to overwrite."
fi

# ---------- install ----------

log "installing firstlaw from: $KIT_BASE_URL"

for rel in $FILES; do
  fetch "$KIT_BASE_URL/$rel" "./$rel"
done

# ---------- next-step ----------

cat <<EOF

Install complete.

Next step:
  Open a new chat with any coding agent (Claude, Codex, Cursor, etc.) and say:

      read CONSTITUTION.md

  The agent will detect that contracts are in skeleton state and run the
  bootstrap protocol at .law/bootstrap/INIT.md.

Kit version: $(cat KIT_VERSION 2>/dev/null || echo '?')
EOF
