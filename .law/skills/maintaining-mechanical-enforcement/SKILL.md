---
name: maintaining-mechanical-enforcement
description: Use when adding a new owned truth to `truth-owners.contract.json`; when adding or changing an `anti_goal` in `project.contract.json`; when adding a new `anti_pattern`; when adding or renaming a domain in `domain-map.contract.json`; when introducing a new persistence layer, ORM, DB driver, or storage backend; when `check-truth-ownership` or `check-anti-patterns` passed even though the truth or anti-goal exists — that is placebo enforcement, populate the pattern fields.
---

# Maintaining Mechanical Enforcement

## Overview
Parameterized enforcers read project-declared patterns. A declared truth without `write_patterns` is prose-only. Populate the pattern fields in the same commit as the declaration, or the enforcement is placebo. §5 and §9 apply.

## When to Use
Triggering symptoms:
- diff adds a new entry under `.law/contracts/truth-owners.contract.json#truths[]`
- diff adds or edits an entry under `.law/contracts/project.contract.json#identity.anti_goals[]`
- diff adds or edits an entry under `.law/contracts/project.contract.json#enforcement.anti_patterns[]`
- diff adds or renames a domain under `.law/contracts/domain-map.contract.json#domains[]`
- stack change lands: new ORM, DB driver, cache, queue, storage backend, or serialization library
- `check-truth-ownership` or `check-anti-patterns` exits zero while a declared truth or anti_goal has `write_patterns` or `forbidden_patterns` empty or absent
- a reviewer asks "which regex catches a violation of this truth?" and no regex exists

Not for use: pure prose edits to charters or doctrine, renaming a field inside a contract entry whose pattern set is already accurate, removing a truth or anti_goal entirely.

## Rule
Every new truth, new or changed `anti_goal`, new `anti_pattern`, new domain, or stack change lands with matching pattern entries in the relevant contract field, in the same commit as the declaration or the code that depends on it. §5 + §9.

## Agent must
- populate `write_patterns[]` on every new `truths[]` entry, with one regex per language the codebase writes in, keyed to the actual syntax used by the declared writer
- populate `forbidden_patterns[]` on every new `anti_goals[]` entry whose violation is keyword-detectable; leave empty only when the anti_goal is abstract and rely on `refusing-anti-goal-creep` for judgment
- populate the regex field on every new `anti_patterns[]` entry; an anti_pattern without a regex is a comment, not an enforcer
- audit every `write_patterns[]` and `anti_patterns[]` regex when introducing a new persistence layer, ORM, DB driver, or storage backend; add entries that match the new syntax before committing code that uses it
- verify each regex against a known-violation fragment and a known-safe fragment before commit; patterns that match nothing are dead
- land the pattern update in the same commit as the declaration or the code change that requires it, per §9 atomicity
- cite §5 and §9 in the commit message when the change touches both truth declarations and pattern fields
- re-run `check-truth-ownership`, `check-anti-patterns`, and `check-skill-voice` after populating patterns; a pass is meaningful only once the patterns exist

## Agent must not
- defer pattern population to a follow-up commit; that is the placebo trap §9 forbids
- treat a green `check-truth-ownership` or `check-anti-patterns` run as evidence of enforcement while `write_patterns` or `forbidden_patterns` is empty or absent
- copy pattern arrays wholesale from another project or from a template without verifying each regex against this codebase's stack
- declare stack-generic patterns (`INSERT INTO`, `UPDATE `) when the project writes through a specific ORM idiom (`prisma.user.create`, `knex('users').insert`)
- leave stale patterns after a stack migration; `knex.insert` regexes that survive a switch to Prisma enforce against code that no longer exists and miss violations in code that does
- treat `forbidden_patterns: []` as equivalent to "abstract anti_goal"; an explicit empty array with a comment noting abstractness is the record, silent omission is not
- land a new domain in `domain-map.contract.json` without checking whether any existing truths now need their `write_patterns` narrowed to files inside that domain

## Rationalizations — STOP and re-read
| Excuse | Reality |
| --- | --- |
| "I'll add the `write_patterns` later — the feature is more urgent." | Later never arrives. The code ships, the pattern does not, and enforcement is placebo. §9: same commit or it did not happen. |
| "The pattern is obvious from the truth's name — `check-truth-ownership` can figure it out." | The script does not infer. It matches the regexes it is given. No regex means no enforcement, no matter how obvious the name. |
| "Our team knows not to write this truth from other modules — we do not need mechanical enforcement." | Team knowledge drifts and new contributors do not inherit it. The regex is how this rule reaches the next contributor without a meeting. |
| "The anti_goal is abstract — I should skip `forbidden_patterns` entirely." | When the anti_goal is abstract, say so explicitly and rely on the judgment skill. When any fragment is keyword-detectable, that fragment belongs in the array. Half-mechanical beats fully-prose. |
| "I switched from knex to Prisma but the existing `write_patterns` still say `knex.insert` — they should still catch accidental regressions." | Stale patterns enforce against code that does not exist and miss violations in code that does. Audit on every stack change. |
| "`check-truth-ownership` passed on this commit, so I am fine." | It passed because the pattern array was empty. An empty array is a no-op. Read the contract before trusting the exit code. |
| "I'll copy the patterns from the other project — they should generally work." | Patterns are stack-specific. A regex tuned to `sqlalchemy` misses violations in a TypeScript+Prisma codebase. Copy invites false confidence. |

## Red flags
- a new `truths[]` entry ships with `write_patterns` empty, absent, or `[]` and no comment explaining abstractness
- a new `anti_goals[]` entry declares a keyword-detectable rule and `forbidden_patterns` is empty
- the stack changed (new ORM, new DB driver, new storage) and no `write_patterns` regex was touched in the same commit
- the same regex string appears verbatim in two unrelated projects' contracts
- `check-truth-ownership` or `check-anti-patterns` exited zero on a commit that declared a new truth or anti_goal and the agent has not opened the contract to confirm non-empty patterns
- an `anti_patterns[]` entry exists with a human-readable `description` field and no `regex` field
- a new domain landed in `domain-map.contract.json` and no existing truth had its `write_patterns` scoped to that domain

## Machine-readable contract
`.law/contracts/truth-owners.contract.json#truths[].write_patterns`, `.law/contracts/project.contract.json#identity.anti_goals[].forbidden_patterns`, `.law/contracts/project.contract.json#enforcement.anti_patterns[]`. Cross-reference enforcers: `.law/bin/check-truth-ownership`, `.law/bin/check-anti-patterns`, `.law/bin/check-skill-voice`. Authority anchor: CONSTITUTION.md §5, §9.
