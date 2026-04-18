---
name: logging-amendments-atomically
description: Use when editing `CONSTITUTION.md`, any `.law/contracts/*.contract.json`, any `.law/charters/*.md`, or any `.law/doctrine/*.md` — the law update, the `last_validated_at` stamp, the `generated_from.run_at` bump when a subagent re-derived the contract, and the amendment-log row at the bottom of `CONSTITUTION.md` must all land in the same commit as the triggering code change.
---

# Logging Amendments Atomically

## Overview

Per §9, a law change that is not co-located with the code change that triggered it, not stamped on the touched contract, and not recorded as a row in the `CONSTITUTION.md` Amendment log did not happen. This skill binds the four moves — code edit, contract update, timestamp stamp, amendment row — into a single atomic commit.

## When to Use

Fire this skill the moment the agent is about to:

- edit `CONSTITUTION.md` (any section, including §0 header fields)
- edit any file under `.law/contracts/` (including `project.contract.json`)
- edit any file under `.law/charters/`
- edit any file under `.law/doctrine/`
- accept subagent-derived output that will overwrite a `.contract.json`
- land a code change that §9's mapping table ties to a contract (new domain, renamed truth owner, new dependency edge, new ambiguity policy, new doc layer, new quality-audit finding, identity/mode/pointer/stack/anti-goal shift)

## Rule

Per `CONSTITUTION.md` §9: any change that affects repo law must update the corresponding contract in the same change, stamp `last_validated_at` on every touched contract, bump `generated_from.run_at` whenever a subagent re-derived the contract, and append a dated row to the Amendment log at the bottom of `CONSTITUTION.md`. The commit without the stamp and the log row is, per §9, an unrecorded amendment and did not happen.

**Why.** Code and law diverge the instant an update is deferred. "Later" never arrives; the diff becomes the only record, and the diff is not the log.

**What failure this prevents.** Contracts drift from code. Reviewers cannot answer "when was this last validated?" or "which commit amended this clause?". The amendment log becomes fiction.

## Agent must

- halt the edit the moment a target path matches §9's mapping table; register the triggering change before typing.
- stamp `last_validated_at` on every `.law/contracts/*.contract.json` touched in the commit, using the current UTC ISO-8601 timestamp.
- update `generated_from.run_at` on any contract re-derived by a subagent in the same commit.
- append one row to the Amendment log table at the bottom of `CONSTITUTION.md` with `YYYY-MM-DD`, a one-line amendment description, and the author identifier.
- update the `Last amended` date at the top of `CONSTITUTION.md` to match the new row when `CONSTITUTION.md` itself changed.
- co-locate the contract update, the stamp, the amendment row, and the code change in the same commit.
- surface and block the commit when any of the four moves is missing; refuse the partial landing.
- follow §9's mapping table literally: new domain → `domain-map.contract.json` plus `.law/charters/<domain>.md`; ownership shift → `truth-owners.contract.json` with amendment note; edge change → `dependency-rules.contract.json`; and so on.

## Agent must not

- defer the amendment row to a follow-up commit, PR, or cleanup pass.
- rely on the commit message, the diff, or CI automation as the amendment record.
- stamp `last_validated_at` without having actually validated the contract against current truth.
- bump `generated_from.run_at` when no subagent re-derivation occurred.
- edit law files across multiple commits when a single commit covers the change.
- soften the §9 table to fit a change the agent would rather land quietly.
- treat the quality-audit advisory exception (§11) as license to skip the amendment log for anything else.

## Rationalizations — STOP and re-read

- "this is a typo fix, no amendment needed" — if the edit touches `CONSTITUTION.md`, a contract, a charter, or a doctrine file, §9 fires. Typo or not, record the row. A one-line "typo: …" entry is the correct record.
- "I'll batch all the amendments at the end" — §9 forbids batching. The commit without the row is an unrecorded amendment. Batching means none of the intermediate states were law.
- "the commit message documents it" — commit messages are not the Amendment log. §9 names the log at the bottom of `CONSTITUTION.md`. Nowhere else counts.
- "it's in the diff, that's the log" — the diff shows the delta, never the dated, authored declaration. §9 demands the declaration.
- "`last_validated_at` is automated in CI" — the kit's `validate-contracts` program checks schema conformance, never freshness. The stamp is the agent's act, not CI's.
- "the contract update is obvious from context" — obviousness is not a record. Reviewers six months later have no context. Record the row.
- "the subagent wrote the contract, so `run_at` is implicit" — `generated_from.run_at` is a field, not an implication. Write the timestamp.

## Red flags

- the agent is about to commit a `CONSTITUTION.md` edit without an Amendment log row in the same diff.
- a contract diff shows field changes with `last_validated_at` unchanged.
- a subagent re-derived a contract and `generated_from.run_at` is `null` or stale.
- the triggering code change sits in one commit and the law update sits in the next.
- the Amendment log row exists but the `Last amended` header date is stale.
- multiple contracts were touched and only one carries the fresh stamp.
- the amendment row says "misc updates" instead of naming the clause amended.

## Machine-readable contract

```json
{
  "skill": "logging-amendments-atomically",
  "constitution_anchor": ["§9", "§0"],
  "triggers": {
    "edit_paths": [
      "CONSTITUTION.md",
      ".law/contracts/*.contract.json",
      ".law/charters/**/*.md",
      ".law/doctrine/**/*.md"
    ],
    "actions": ["edit", "create", "rename", "subagent_regenerate"]
  },
  "required_moves_per_commit": [
    "update_contract_per_section_9_mapping_table",
    "stamp_last_validated_at_on_every_touched_contract",
    "bump_generated_from_run_at_when_subagent_rederived",
    "append_row_to_constitution_amendment_log",
    "update_constitution_last_amended_header_when_constitution_changed",
    "co_locate_with_triggering_code_change"
  ],
  "amendment_row_fields": ["date_yyyy_mm_dd", "amendment_one_line", "author"],
  "refuse_if": [
    "amendment_row_missing",
    "last_validated_at_unchanged_on_touched_contract",
    "generated_from_run_at_stale_after_subagent_rederivation",
    "law_edit_and_code_change_in_separate_commits"
  ],
  "authority": "CONSTITUTION.md §9 + Amendment log section"
}
```
