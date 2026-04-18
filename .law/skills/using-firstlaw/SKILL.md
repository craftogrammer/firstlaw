---
name: using-firstlaw
description: Use at the first turn of any session in a repo containing `CONSTITUTION.md` and a `.law/` directory; also use whenever an agent is about to act before reading repo law; also use when a tool-facing adapter (`CLAUDE.md`, `AGENTS.md`, `codex.md`, `.cursorrules`) appears to contradict `CONSTITUTION.md` or a contract under `.law/contracts/`; also use when the user says "setup firstlaw", "check firstlaw", "audit firstlaw", "heal firstlaw", or "is firstlaw set up" — route to `auditing-firstlaw-integrity` for the audit workflow
---

# Using Firstlaw

## Overview

This repo is governed by firstlaw. `CONSTITUTION.md` and `.law/` are law; everything else is subordinate. This skill routes to the cold-read protocol before any action.

## Rule

`CONSTITUTION.md` and `.law/` top the truth hierarchy. Act only after the cold-read completes.

## Agent must

- invoke the `cold-reading-the-repo` skill as the first action of the session
- follow the precedence ladder: constitution > contracts > doctrine+charters > context > adapters
- halt and surface the conflict when a lower layer contradicts a higher layer
- cite the governing contract path on any binding decision

## Agent must not

- answer, plan, or edit before the cold-read completes
- treat `CLAUDE.md`, `AGENTS.md`, `codex.md`, or `.cursorrules` as law
- resolve layer contradictions silently
- treat the cold-read as complete when `.law/bin/check-setup` surfaces an irreducible blocker — halt and report before acting on the user's request

## Machine-readable contract

`.law/contracts/project.contract.json` — identity, mode, pointers, `status`. See `.law/KIT_INDEX.md` for full kit inventory.
