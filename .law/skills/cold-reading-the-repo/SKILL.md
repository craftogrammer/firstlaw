---
name: cold-reading-the-repo
description: Use when any session starts in a firstlaw-governed repo (root contains `CONSTITUTION.md`) — before answering the user's question, reading arbitrary files, planning, acting, or even clarifying. Fires on the first user message of a conversation. Fires again after any context reset or compaction. Symptoms that the skill was skipped: the agent opened a source file before running `.law/bin/` scripts; the agent asked "Want me to read `KIT_INDEX.md` next?"; the agent branched on `project.contract.json#status` without reading it; the agent answered a "simple" question without consulting `.law/context/pending-questions.json`. Also use when the user references kit-version drift, healing, setup, or when a session starts in a repo where `.law/bin/check-setup` has never been run.
---

# Cold Reading The Repo

## Overview

The COLD-READ PROTOCOL at the top of `CONSTITUTION.md` (lines 3–33, governing §0 and §1) binds every agent entering a firstlaw repo. It is a **single continuous action**: follow `CONSTITUTION.md` → follow `.law/KIT_INDEX.md` → follow `.law/contracts/project.contract.json` and branch on `status` → consult `.law/context/current-system.json` → consult `.law/context/pending-questions.json` and `last-check.log` → execute the three kit-integrity scripts in `.law/bin/`. The agent ends the turn only when a defined blocker fires. Summarize-and-ask between steps is a **violation**, not a turn boundary.

This skill is the workflow enforcement layer. Skipping steps is the failure mode.

## When to Use

- The first user message of any conversation in a repo with `CONSTITUTION.md` at the root.
- Any turn after a context reset, compaction, `/clear`, or resume into a firstlaw repo.
- Any moment the agent notices it is about to act — read source, plan, answer, edit, run — without having executed the six cold-read steps in this session.
- The instant a rationalization surfaces for partial compliance ("the question is small", "I read it last session", "the user is impatient").

## Rule

**Execute the cold-read sequence as a single continuous action. Halt only on a defined blocker. Never hand control back between steps.**

The sequence, verbatim from `CONSTITUTION.md` §0-adjacent COLD-READ PROTOCOL:

1. Follow `CONSTITUTION.md` in full.
2. Follow `.law/KIT_INDEX.md`.
3. Follow `.law/contracts/project.contract.json` and branch on `status`:
   - `skeleton` or `bootstrapping` → follow `.law/bootstrap/INIT.md` and execute that protocol. The cold-read continues **into** bootstrap; it does not pause.
   - `active` → consult the contracts, doctrine, and charters relevant to the current task. Do not read everything.
4. Consult `.law/context/current-system.json` if present.
5. Consult `.law/context/pending-questions.json`. Consult `.law/context/last-check.log` if it exists.
6. Execute `.law/bin/verify-adapters`, `.law/bin/validate-contracts`, and `.law/bin/check-counts`. Non-zero exit from any = halt and report the failures to the user before acting on the task. If the shell is unavailable, skip and record the fact.

**Why this exists.** The truth hierarchy in `CONSTITUTION.md` §1 is only binding when the agent has actually loaded it. A partial cold-read guarantees the agent acts on a stale map, contradicts a higher layer without noticing, or skips the blocking elicitation questions defined by the bootstrap protocol. Summarize-and-ask fragments the sequence into six approval gates the protocol forbids.

**What failure this prevents.** The agent answers a "simple" question, edits a file, or invents a plan while `status: skeleton` still holds — violating §0 of `CONSTITUTION.md`, bypassing `.law/bootstrap/INIT.md`, and committing work the contracts have not yet authorized.

**Machine-readable contract.** `.law/contracts/project.contract.json#agent_directives.on_session_start` enumerates the load order; `#status` gates the branch; the three scripts in `.law/bin/` enforce kit integrity.

## Agent must

- Execute all six steps in order, in one turn, without requesting permission between them.
- Read `CONSTITUTION.md` in full — the comment block AND the numbered sections — before opening any other file.
- Branch strictly on `.law/contracts/project.contract.json#status`. On `skeleton` or `bootstrapping`, follow `.law/bootstrap/INIT.md` as a continuation of the same turn.
- Consult `.law/context/pending-questions.json` for blocking entries and surface every `blocking: true` entry to the user before acting on the original request.
- Execute `.law/bin/verify-adapters`, `.law/bin/validate-contracts`, and `.law/bin/check-counts`. Halt on any non-zero exit and report the failures verbatim.
- run `.law/bin/check-setup` before the detection checks; allow it to self-commit heals when the working tree is clean; surface any irreducible items before the detection phase
- Record a single-line status announcement per step (e.g. "CONSTITUTION.md loaded", "status=skeleton, entering bootstrap", "verify-adapters OK") — these are progress indicators, not turn boundaries.
- Treat shell unavailability as a narrow exception: skip the `.law/bin/` step, note the skip in the session output, and continue.
- Resume the sequence from the last incomplete step after any defined blocker clears.

## Agent must not

- End the turn between steps 1 and 6 for any reason other than a defined blocker (blocking elicitation, quality-audit gate, 60-minute overrun, non-zero script exit).
- Emit any summarize-and-ask variant. The protocol cites these verbatim as explicit violations (CONSTITUTION.md lines 26–28):

  ```
  "I've read CONSTITUTION.md. Want me to read KIT_INDEX.md next?"
  "Status is skeleton. Should I open INIT.md?"
  "Here's what I found so far — should I proceed?"
  ```

  Delete the question. Continue reading.
- Read "only what seems relevant" in place of step 1, step 2, or step 3. Steps 1–3 are declared non-negotiable by `CONSTITUTION.md` line 32.
- Skip the `.law/bin/` scripts because they "probably pass". Non-zero exit is a halt condition the agent cannot predict.
- Rely on memory of a prior session's cold-read. A new session is a new turn; the load order runs fresh.
- Act on the user's request before step 6 completes or a blocker fires. No exceptions for "quick" questions, "trivial" edits, or "obvious" answers.
- Interleave the user's original task into the sequence. The sequence runs first, in full, then the task.

## Rationalizations — STOP and re-read

- *"The user's question is simple, the full cold-read is overkill."* — The protocol makes no exception for simple questions. A "simple" question answered against a `skeleton`-status contract is still a §1 precedence violation. Execute the sequence.
- *"I did the cold-read last session on this repo."* — `CONSTITUTION.md` line 4 binds **every session**. Context does not persist across sessions. The contracts, `pending-questions.json`, and `last-check.log` may have changed since the last load. Execute the sequence.
- *"I'll read what's relevant as I go."* — `.law/KIT_INDEX.md` line 50 permits selective reading **only** when `status` is `active`, and only **after** the six-step cold-read has established that status. "As I go" is the failure pattern the protocol names.
- *"The user is impatient — I'll answer first and read after."* — Acting before step 6 is the exact violation the protocol forbids. Impatience is not a defined blocker. Execute the sequence; announce progress in one-line status messages; do not apologize for following the law.
- *"I'll summarize progress halfway through as a courtesy."* — `CONSTITUTION.md` line 6 forbids mid-sequence summary-and-ask. Courtesy to the user is executing the protocol correctly, not narrating a pause that does not exist.
- *"The `.law/bin/` scripts always pass on this repo."* — Past green runs do not bind the current state. Non-zero exit is a defined halt condition. Run them.
- *"Shell is slow, I'll skip the scripts this once."* — Shell cost is not a defined exception. Only shell **unavailability** permits the narrow skip, and the skip is recorded.
- *"check-setup heals feel invasive — I will apply them manually."* — The script is idempotent, auto-commits only when the tree is clean, and records every heal in the amendment log. Manual editing bypasses the audit trail and violates §9 mutation rules.

## Red flags

Halt and re-enter the sequence the instant any of these appear in the agent's own output or internal planning:

- Any of the three verbatim violations cited by `CONSTITUTION.md` lines 26–28:

  ```
  "I've read CONSTITUTION.md. Want me to read KIT_INDEX.md next?"
  "Status is skeleton. Should I open INIT.md?"
  "Here's what I found so far — should I proceed?"
  ```

- "Let me just check one file first to answer the user's question" — acting before step 6.
- "I'll run the scripts after I draft a response" — reversing the protocol order.
- "The contracts look fine at a glance" — skipping validation.
- Any phrasing that requests approval to transition between steps 1→2, 2→3, 3→4, 4→5, or 5→6.
- Any plan that reads a source file, opens an editor, or emits an answer before `.law/bin/check-counts` has executed (or been validly skipped).
- Any branch on `status` without having actually read `project.contract.json` in the current turn.

## Machine-readable contract

```yaml
trigger:
  event: session_start
  precondition:
    - repo_root_contains: CONSTITUTION.md
  fires_also_on:
    - context_reset
    - compaction
    - resume_into_firstlaw_repo

sequence:
  - id: 1
    action: read_in_full
    path: CONSTITUTION.md
  - id: 2
    action: read_in_full
    path: .law/KIT_INDEX.md
  - id: 3
    action: read_and_branch
    path: .law/contracts/project.contract.json
    branch_on: status
    branches:
      skeleton:
        continue_into: .law/bootstrap/INIT.md
      bootstrapping:
        continue_into: .law/bootstrap/INIT.md
      active:
        consult: task_relevant_contracts_doctrine_charters
  - id: 4
    action: consult_if_present
    path: .law/context/current-system.json
  - id: 5
    action: consult
    paths:
      - .law/context/pending-questions.json
      - .law/context/last-check.log   # if present
    surface_to_user:
      - entries_where: "blocking == true"
  - id: 6
    action: execute
    commands:
      - .law/bin/check-setup
    purpose: self-heal remediable kit-version drift; auto-commit heals when tree is clean; surface irreducible items
    on_nonzero_exit: halt_and_report
    on_shell_unavailable: skip_and_record
  - id: 7
    action: execute
    commands:
      - .law/bin/verify-adapters
      - .law/bin/validate-contracts
      - .law/bin/check-coupling
      - .law/bin/check-counts
    on_nonzero_exit: halt_and_report
    on_shell_unavailable: skip_and_record

turn_end_conditions:
  - all_six_steps_complete_in_operate_mode
  - blocking_elicitation_reached
  - quality_audit_acknowledgement_gate_fires
  - sixty_minute_overrun_checkpoint_fires
  - kit_integrity_script_nonzero_exit

violations:
  - summarize_and_ask_between_steps
  - request_approval_to_transition
  - act_on_user_request_before_step_6
  - rely_on_prior_session_cold_read
  - skip_steps_1_through_3   # declared non-negotiable by CONSTITUTION.md line 32
  - "check-setup reported heals — should I commit them?"

anchors:
  constitution: "CONSTITUTION.md §0, §1, top comment block lines 3–33"
  kit_index: ".law/KIT_INDEX.md §How an agent enters"
  bootstrap: ".law/bootstrap/INIT.md §0.1 Autonomy rule"
  contract_field: ".law/contracts/project.contract.json#status"
  directives_field: ".law/contracts/project.contract.json#agent_directives.on_session_start"
```
