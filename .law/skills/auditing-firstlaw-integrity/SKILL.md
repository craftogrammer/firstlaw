---
name: auditing-firstlaw-integrity
description: Use when the user says "setup firstlaw"; "check firstlaw"; "audit firstlaw"; "heal firstlaw"; "is firstlaw set up"; "verify firstlaw"; "fix firstlaw"; "firstlaw drift"; also use when a cold-read run emits `firstlaw check-setup` output listing `healed:`, `surfaced:`, or `committed:` items; also use when the user pastes error output referencing `.law/bin/`, `.law/contracts/`, or a missing `.law/context/last-check.log`; also use when an adapter patch block or a doc-taxonomy layer appears stale against `KIT_VERSION`.
---

# Auditing Firstlaw Integrity

## Overview

`CONSTITUTION.md` §11 binds the agent to correct violations at the point of discovery; §12 enumerates what the kit enforces versus what the project owns and names `.law/bin/check-setup` as the self-healing entry point. This skill routes every firstlaw-integrity request through that executable and enforces its commit-when-clean / review-when-dirty semantics.

## When to Use

- The user says "setup firstlaw", "check firstlaw", "audit firstlaw", "heal firstlaw", "is firstlaw set up", "verify firstlaw", "fix firstlaw", or any close variant.
- A cold-read turn surfaces output beginning with `firstlaw check-setup` and listing `healed:`, `surfaced:`, or `committed:` blocks.
- The user pastes error output that references `.law/bin/`, a missing `.law/context/last-check.log`, a stale adapter patch, or an unwired pre-commit hook.
- `KIT_VERSION` bumped and the kit-owned layers drifted against the shipped contract skeleton.

**Do not use** in the middle of an unrelated task, or as a substitute for the cold-read itself — `.law/skills/cold-reading-the-repo/SKILL.md` runs first; this skill fires only on explicit integrity triggers or on cold-read surfaces.

## Rule

`.law/bin/check-setup` is the single source of truth for firstlaw-installation health. Invoke it; follow its output; halt on its blockers.

## Agent must

- Run `python3 .law/bin/check-setup` from the repo root. Cross-platform: invoke via `python3`, not `bash`, to sidestep the Windows shebang resolution issue.
- Read the structured output in full: the `healed:`, `surfaced:`, and `committed:` blocks.
- When the script auto-committed heals, verbatim-surface the commit list and hashes to the user.
- When the script reports `working tree was dirty; heals NOT committed`, run `git diff --stat`, print the output, and instruct the user to review and commit the heals before the current task resumes.
- When the script surfaces irreducible items, halt the current task, report each item with its contract path and field, and ask the user to make the decisions the script refuses to make.
- Respect the script's exit code: `0` proceed; `1` halt and surface blockers; `2` internal error, report verbatim and stop.

## Agent must not

- Hand-edit `.law/contracts/*.contract.json` to bypass a `check-setup` surface.
- Hand-edit `.law/context/last-check.log` to mask a prior failure.
- Invoke `check-setup` via `bash .law/bin/check-setup` when `python3` resolves; the polyglot shebang exists as a fallback, and `python3` invocation keeps the interpreter explicit.
- Declare the kit healthy from visual inspection of the tree.
- Suppress `check-setup` output with `2>/dev/null`, `|| true`, or any redirection that drops the exit code.
- Bundle healed changes into an unrelated task commit; heals land as their own commit authored by `check-setup`.

## Red flags

Halt and re-read this skill the instant any of these surface in the agent's own planning:

- "I can fix the doc-taxonomy layer drift by hand-editing `.law/contracts/doc-taxonomy.contract.json`."
- "`check-setup` is overkill for this small drift — one line edit resolves it."
- "I will apply the heals manually and roll them into the current task commit."
- "The heal list looks invasive; I will skip running `check-setup` this session."
- "Working tree is dirty but I will let `check-setup` commit heals alongside my task changes."
- "`check-setup` surfaced an irreducible item but I know the fix — I will resolve it silently."
- "The Windows shebang failed, so I will patch the shebang instead of invoking via `python3`."

## Machine-readable contract

`.law/bin/check-setup` — the executable that enforces this skill's discipline; its exit code and output blocks bind the agent's next action.

Cross-reference: `.law/contracts/project.contract.json#adapters.patched_files` and `#enforcement.coupled_paths` — the fields `check-setup` reads to decide what to heal and what to surface.
