---
name: using-firstlaw
description: Use at session start in a repo with `CONSTITUTION.md` and `.law/`; before acting on law; when `CLAUDE.md`/`AGENTS.md`/`codex.md`/`.cursorrules` contradict `CONSTITUTION.md` or `.law/contracts/`; on "setup/check/audit/heal firstlaw" — routes to `auditing-firstlaw-integrity`.
---

# Using Firstlaw

## Overview

`CONSTITUTION.md` and `.law/` top the truth hierarchy (§1); all else subordinate.

## Rule

Act only after cold-read completes.

## Agent must

- invoke `cold-reading-the-repo` first
- follow precedence (§1): constitution > contracts > doctrine+charters > context > adapters
- halt on contradictions
- invoke `auditing-firstlaw-integrity` on setup/audit/health

## Agent must not

- answer before cold-read completes
- treat `CLAUDE.md`, `AGENTS.md`, `codex.md`, `.cursorrules` as law
- treat `.law/bin/check-setup` surfaces as complete work

## Machine-readable contract

`.law/contracts/project.contract.json` — identity, mode, pointers. Kit inventory: `.law/KIT_INDEX.md`.
