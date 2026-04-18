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
# Idempotent. Two categories of files:
#   Kit files     (constitution, scripts, schemas, doctrine, subagent contracts,
#                  bootstrap protocol, templates): overwritten on --force.
#   Template files (.law/contracts/*, .law/context/current-system.json,
#                  .law/context/pending-questions.json): NEVER overwritten
#                  — after bootstrap these hold project law. --force ignores them.
#                  Delete manually if you truly want to re-bootstrap from skeleton.
#
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
      cat <<'EOF'
firstlaw installer

Usage:
  curl -fsSL https://raw.githubusercontent.com/craftogrammer/firstlaw/main/install.sh | sh
  curl -fsSL https://raw.githubusercontent.com/craftogrammer/firstlaw/main/install.sh | sh -s -- --force

Behavior:
  Fresh install writes 46 files (CONSTITUTION.md + KIT_VERSION + .law/).
  --force upgrades KIT_FILES (constitution, scripts, schemas, doctrine,
  bootstrap, subagent contracts, templates). TEMPLATE_FILES (.law/contracts/*
  and .law/context/current-system.json + pending-questions.json) are NEVER
  overwritten — they hold project law after bootstrap.

  To reset contracts to skeleton, delete them manually and re-run install.

After install, open a new chat with any agent and say: "follow CONSTITUTION.md"
EOF
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
  # fetch <url> <dest>  — respects --force (overwrites existing if FORCE=1)
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

fetch_once() {
  # fetch_once <url> <dest>  — NEVER overwrites; preserves project-populated files
  _url="$1"; _dest="$2"
  _dir="$(dirname "$_dest")"
  [ -d "$_dir" ] || mkdir -p "$_dir"
  if [ -e "$_dest" ]; then
    log "preserve: $_dest"
    return 0
  fi
  curl -fsSL "$_url" -o "$_dest" || die "download failed: $_url"
  log "wrote: $_dest"
}

# ---------- file manifests ----------
# Two lists. KIT_FILES upgrade on --force. TEMPLATE_FILES install-once and
# are never overwritten, because after bootstrap they contain project law
# (populated contracts, regenerated snapshots). Clobbering them destroys work.

KIT_FILES="
CONSTITUTION.md
KIT_VERSION
.gitattributes
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
.law/schemas/project.schema.json
.law/schemas/domain-map.schema.json
.law/schemas/truth-owners.schema.json
.law/schemas/dependency-rules.schema.json
.law/schemas/ambiguity-policies.schema.json
.law/schemas/doc-taxonomy.schema.json
.law/schemas/quality-audit.schema.json
.law/schemas/subagent-envelope.schema.json
.law/schemas/current-system.schema.json
.law/schemas/agent-runtime.schema.json
.law/contracts/agent-runtime.contract.json
.law/doctrine/product.md
.law/doctrine/architecture.md
.law/doctrine/agent-behavior.md
.law/charters/README.md
.law/charters/example-domain.md
.law/context/research/README.md
.law/bin/README.md
.law/bin/verify-adapters
.law/bin/validate-contracts
.law/bin/check-coupling
.law/bin/check-amendment-coupling
.law/bin/check-counts
.law/bin/check-setup
.law/git-hooks/pre-commit.sample
.law/templates/README.md
.law/templates/check-truth-owners.example.mjs
.law/templates/check-dep-direction.example.mjs
.law/templates/check-anti-patterns.example.mjs
.law/skills/halting-on-ambiguity/SKILL.md
.law/skills/checking-truth-ownership-before-mutating/SKILL.md
.law/skills/checking-dep-edges-before-importing/SKILL.md
.law/skills/refusing-anti-goal-creep/SKILL.md
.law/skills/resolving-layer-conflicts/SKILL.md
.law/skills/grounding-with-dated-research/SKILL.md
.law/skills/logging-amendments-atomically/SKILL.md
.law/skills/cold-reading-the-repo/SKILL.md
.law/skills/running-brownfield-discovery/SKILL.md
.law/skills/classifying-before-authoring/SKILL.md
.law/skills/surfacing-forbidden-edges/SKILL.md
.law/skills/authoring-project-skills/SKILL.md
.law/skills/auditing-firstlaw-integrity/SKILL.md
.law/skills/using-firstlaw/SKILL.md
"

TEMPLATE_FILES="
.law/contracts/project.contract.json
.law/contracts/domain-map.contract.json
.law/contracts/truth-owners.contract.json
.law/contracts/dependency-rules.contract.json
.law/contracts/ambiguity-policies.contract.json
.law/contracts/doc-taxonomy.contract.json
.law/contracts/quality-audit.contract.json
.law/context/current-system.json
.law/context/pending-questions.json
"

# ---------- preflight ----------

if [ -f CONSTITUTION.md ] && [ "$FORCE" -ne 1 ]; then
  log "note: CONSTITUTION.md already exists. Re-run with --force to upgrade kit files."
fi

# ---------- install ----------

log "installing firstlaw from: $KIT_BASE_URL"

for rel in $KIT_FILES; do
  fetch "$KIT_BASE_URL/$rel" "./$rel"
done

for rel in $TEMPLATE_FILES; do
  fetch_once "$KIT_BASE_URL/$rel" "./$rel"
done

# ---------- next-step ----------

cat <<EOF

Install complete.

Next step:
  Open a new chat with any coding agent (Claude, Codex, Cursor, etc.) and say:

      follow CONSTITUTION.md

  The agent runs the cold-read protocol, which self-heals any remediable
  kit-version drift before acting on your request. v1.4 ships a real
  cross-domain import checker (check-coupling) and treats brownfield
  contradictions with matching open plans as pass-with-warning. Re-run
  this installer with --force anytime to pull new kit features; the
  next cold-read heals your project to match.

Kit version: $(cat KIT_VERSION 2>/dev/null || echo '?')
EOF
