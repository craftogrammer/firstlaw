---
name: authoring-project-skills
description: Use when the same agent rationalization surfaces in two or more sessions ("we keep tripping on X"), when a newly-observed agent failure mode has no existing Layer B skill covering it, when the user explicitly requests a new skill ("write me a skill for Y", "codify this discipline"), when a domain declared in `.law/contracts/domain-map.contract.json` has a charter and truth-owners entry but no matching Layer B reference skill whose absence lets domain-specific errors recur, when a contract is amended in a way that changes the cognitive moment an agent faces at a domain boundary, or when a pressure-test of an existing Layer B skill shows it fails to fire on its declared symptoms. Covers authoring the new skill file at the runtime-discoverable path, grounding it in the project's contracts and charters (never kit-universal disciplines), performing live web research on the current skill-format spec with dated retrieval URLs, dispatching a pressure-scenario subagent without the skill then with the skill to confirm both load and bite, committing, and surfacing a single reload-required line to the user. Anchors: CONSTITUTION.md §3, §9, §10.
---

# Authoring Project Skills

## Overview

A project skill is an adapter-class projection (CONSTITUTION.md §3) that loads into an agent runtime and alters agent behavior at a specific cognitive moment. Skills are non-authoritative by construction: repo law lives in `CONSTITUTION.md` and `.law/contracts/*`, and a skill is defective the instant it contradicts a contract it claims to ground in. Skills exist in two classes. **Layer A** skills encode kit-universal disciplines (examples from the parallel batch: `checking-dep-edges-before-importing`, `consulting-contracts-before-acting`). **Layer B** skills are project-specific, named after a domain's actual function as declared in `.law/contracts/domain-map.contract.json`, and bound to that domain's charter and `truth-owners.contract.json` entries. A Layer B skill is never named `working-in-domain-X`, `helper-for-X`, or any meta-label — it is named for the cognitive moment it fires on (`validating-payment-amounts-before-persistence`, `resolving-tenant-before-query`), the same shape Layer A skills use.

This skill is the self-replicating seed for Layer B: it teaches the authoring process itself. It fires when a recurring workflow gap is observed across sessions, or when the project acquires a domain whose charter reveals a per-domain reference skill would prevent specific recurring errors.

Two failure modes govern every skill, and this one is no exception:

- **MISSED LOAD** — the `description` frontmatter fails to fire when the authoring opportunity arises. The agent writes a second skill instead of recognizing the cognitive moment, or silently patches a symptom that a skill would have caught at the gate.
- **SKIPPED ENFORCEMENT** — the skill loads but the agent routes around its body. Live research on the format gets replaced with training recall; the reload reminder gets dropped; the pressure-test gets deferred "until later."

The body below forbids both. CONSTITUTION.md §10 lists "Skipping research" as a named agent failure mode; §3 declares adapters non-authoritative and forbids encoding project law inside them; §9 governs mutation rules and requires contract amendment before shipping a skill that would contradict an existing contract. All three anchors bind every line of this skill.

## When to Use

**Layer A vs Layer B.** A skill is **Layer A** (ships with the kit) if it enforces a `CONSTITUTION.md` article. A skill is **Layer B** (project-specific) if it enforces a domain declared in `.law/contracts/domain-map.contract.json`. Layer A is universal; Layer B is per-project. This skill authors Layer B.

Fire this skill the instant any of the following holds:

- the same agent rationalization appears in two or more sessions on this repo (recurring workflow gap)
- a newly-observed agent failure mode has no existing Layer B skill covering its cognitive moment
- the user requests a new skill explicitly: "write me a skill for Y", "codify this", "we keep tripping on X"
- a domain in `.law/contracts/domain-map.contract.json` has a charter and a `truth-owners.contract.json` entry but no matching Layer B reference skill, and recent sessions show errors specific to that domain's boundary
- a contract is amended in a way that shifts the cognitive moment an agent faces (new ambiguity policy, new dependency edge category, new truth-owner class)
- a pressure-test of an existing Layer B skill shows it no longer fires on its declared symptoms, and the right response is a new or replacement skill rather than a patch
- a skill authored in this repo has been shipped without a pressure-test envelope recorded under `.law/context/research/` — treat the gap as a fire of this skill

## Rule

Before authoring, authoring, and after authoring a project skill:

1. **Identify the cognitive moment.** State in one sentence what the agent is about to do when the skill must fire. If the sentence contains "when working on X" or "when the user asks", the moment is too vague — halt and reframe as a concrete action the agent is typing or dispatching.
2. **Classify Layer A vs Layer B.** Layer A = kit-universal, grounded in `CONSTITUTION.md` and kit contracts. Layer B = project-specific, grounded in a named domain's charter plus `truth-owners.contract.json` entry. A skill that fits neither class is ill-conceived — halt and surface.
3. **Research the current skill format.** Perform live web research on the target agent runtime's skill-format specification with retrieval dates. Record the dated URLs in `.law/context/research/authoring-project-skills-<YYYY-MM-DD>.json`. Training-only authoring is rejected by §10.
4. **Ground the body in contracts.** Every rule, must, and must-not cites a contract field, a charter section, or a constitution article. Assertions without an anchor are removed before commit.
5. **Author at the runtime-discoverable path.** Skill loading differs per runtime. Consult `.law/contracts/agent-runtime.contract.json` for the current runtime's load model and discovery path. Example: Claude Code 2026-04 supports live edit detection for existing skill directories; new directories still require session restart. Cursor reloads rules files at session start. Codex: unknown (requires live research). Do not assume a single load model across runtimes. Record the runtime path and load model in the skill's pressure-test envelope.
6. **Write the frontmatter description as the load gate.** The description lists the concrete symptoms that cause the runtime to load the skill. A vague description MISSES LOAD. Three or more distinct triggers are the floor.
7. **Write the body as the enforcement gate.** Rule, Agent must, Agent must not, Rationalizations, Red flags, Machine-readable contract. No softening verbs. Imperative voice only.
8. **Pressure-test before ship.** Dispatch a subagent with the project's contracts loaded but without the new skill; present a scenario that must trigger the skill; record behavior. Dispatch a second subagent with the skill loaded; present the same scenario; record behavior. Confirm the skill both **fires** (loaded on the matching symptom) and **bites** (follows the body's enforcement). If either fails, the skill is broken — do not commit.

   **Single-agent fallback.** When no subagent dispatch is available, document the expected before/after behavior explicitly in the research envelope (`.law/context/research/<skill-name>-<date>.json`): a `pressure_test` object with `baseline_expected_behavior` (prose describing what an agent would naturally do without this skill) and `with_skill_expected_behavior` (prose describing what this skill forces). Both must be concrete — name the exact code path, SQL, or decision the skill bites on. Handwaving (e.g. "the agent would behave correctly") fails the pressure test and the skill is not shipped.
9. **Commit and surface the reload line.** End the session with a single clear line: `Skill \`<name>\` committed to \`<runtime-path>\`. Reload your agent runtime for it to become discoverable.` Do not claim the skill is active in the current session.
10. **Register the skill** in the project's skill index (if one exists) and append a row to the skill's pressure-test envelope. Run `.law/bin/validate-contracts` and `.law/bin/verify-adapters`; block on non-zero exit.

## Agent must

- fire on recurring rationalizations, on uncovered failure modes, on explicit user requests, and on uncovered Layer B domains — classify before authoring
- perform live web research on the target runtime's current skill-format spec and record dated retrieval URLs under `.law/context/research/`
- ground Layer B skill bodies in the domain's charter plus `truth-owners.contract.json` entry, and cross-link both paths in the body
- name Layer B skills after the cognitive moment (imperative gerund: `validating-X-before-Y`, `resolving-X-before-Z`), never `working-in-<domain>` or `helper-for-<domain>`
- write the `description` frontmatter as the load gate — three or more distinct, concrete triggers, each naming an observable agent action
- write the body using the scaffold: Overview, When to Use, Rule, Agent must, Agent must not, Rationalizations, Red flags, Machine-readable contract
- cite `CONSTITUTION.md` articles by number in the body and cite every contract the skill grounds in by path
- halt the authoring session on any contradiction between the proposed skill and an existing contract or charter; amend the contract through §9 mutation rules before resuming
- pressure-test by dispatching two subagents (without-skill, with-skill) on an identical scenario and recording both envelopes before commit
- refuse to ship unless both envelopes show the skill fires on the matching symptom and bites when loaded
- surface a single-line reload reminder at end-of-session: `Skill \`<name>\` committed to \`<path>\`. Reload your agent runtime for it to become discoverable.`
- record the authored skill in the project's skill index (path, class, cognitive moment, anchors, research-envelope path)
- run `.law/bin/validate-contracts` and `.law/bin/verify-adapters` and block on non-zero exit
- re-read CONSTITUTION.md §3 and §10 whenever the authoring impulse includes the phrase "I already know the format"

## Agent must not

- compile a skill programmatically from a contract — skill authoring requires judgment about the cognitive moment and live research on the format
- author from training recall alone, skipping the dated-URL research step (§10 rejects training-only claims on current-state questions)
- name a Layer B skill `working-in-<domain>`, `helper-for-<domain>`, `<domain>-utilities`, `<domain>-guide`, or any meta-label
- ship a skill whose body encodes project law that belongs in a contract (§3 forbids adapter-class law)
- ship a skill without a pressure-test envelope recording both without-skill and with-skill runs
- claim the skill is active in the current session without consulting `.law/contracts/agent-runtime.contract.json` for the current runtime's load model — skill loading differs per runtime; example: Claude Code 2026-04 supports live edit detection for existing skill directories, new directories still require session restart; Cursor reloads rules files at session start; Codex: unknown (requires live research); do not assume a single load model across runtimes
- drop the reload line at end-of-session, or soften it into a question ("do you want to reload?")
- commit a skill that contradicts an existing charter, contract, or constitution article instead of amending the conflicting layer first
- use softening verbs (`should`, `try to`, `consider`, `prefer`, `usually`, `generally`, `might`) anywhere in the skill body — Layer B skills match the Layer A voice exactly
- author a new skill when the correct action is amending an existing skill's description to fire on the missed symptom
- defer the pressure-test "until the next session" — an unvalidated skill silently rots
- bypass `.law/bin/validate-contracts` or `.law/bin/verify-adapters` with `|| true`, `--no-verify`, or silent skip

## Rationalizations — STOP and re-read

| Rationalization the agent whispers | Why it is still forbidden |
|---|---|
| "I know the skill format cold from training." | §10: skipping research is a named failure mode. The format spec moves; 2024 recall fails a 2026 author. Fetch dated URLs. |
| "I'll ship now and pressure-test later." | An unvalidated skill MISSES LOAD or SKIPS ENFORCEMENT silently. Both failure modes defeat the point. Pressure-test before commit. |
| "The runtime picks up skills automatically — no reload needed." | Load models differ per runtime. Consult `.law/contracts/agent-runtime.contract.json` for the current runtime's load model and discovery path. Claude Code 2026-04 hot-reloads file edits in existing skill directories; new directories still require session restart. Cursor reloads rules files at session start. Codex: unknown (requires live research). Surface the reload line unless the runtime contract declares live-edit detection for the change class (file edit vs new directory). |
| "I'll compile this skill from the contract fields." | Skills encode cognitive moments, not contract schemas. Compilation produces a manifest, not a skill. Author with judgment. |
| "One scenario is enough to verify it fires." | A single without-skill run proves nothing about the with-skill bite. Run both envelopes on the same scenario. |
| "This is Layer B, so the voice can be softer than Layer A." | Layer B matches Layer A voice exactly. Softening verbs leak enforcement and MISS BITE. Zero softening. |
| "I'll name it `working-in-billing` so it is obvious." | Meta-labels fail to fire on the cognitive moment. Name after the action the agent is about to take at the domain boundary. |
| "The skill contradicts the dependency contract, but the contract is out of date." | §9: amend the contract first. Shipping a skill that contradicts a contract produces silent law-vs-law conflict. |
| "The user already knows to reload." | The reload line is for the transcript and for the next agent reading it. Surface it every time. |
| "I'll drop the research envelope because the URLs are obvious." | The envelope is the audit trail. §10 requires dated retrieval. No envelope = no research. |
| "I'll put the project's law in this skill so the runtime enforces it." | §3 forbids law in adapter-class files. Amend the contract; let the skill reference it. |
| "The existing skill almost fires — I'll write a sibling instead of amending the description." | Two near-duplicate descriptions fragment the load gate. Amend the existing description. |

## Red flags

Halt and re-check if any of these appear:

- a skill authored in the same commit as the contract it grounds in, without an Amendment log row
- a `description` frontmatter with fewer than three concrete triggers, or triggers phrased as "when working on X"
- a Layer B skill whose name contains `working-in`, `helper-for`, `utilities`, `guide`, `docs`, or the bare domain name
- a body that asserts a rule without citing a constitution article or a contract path
- any occurrence of `should`, `try to`, `consider`, `prefer`, `usually`, `generally`, `might` in the body
- no `.law/context/research/authoring-project-skills-<YYYY-MM-DD>.json` envelope for the current author session
- no pressure-test envelope pair (without-skill, with-skill) recorded under `.law/context/research/`
- the commit message or session transcript omits the `Skill \`<name>\` committed ... Reload your agent runtime` line
- a skill body that encodes identity, domain boundaries, truth ownership, dependency rules, or ambiguity policies in a form that could diverge from the contracts (§3 violation)
- `.law/bin/validate-contracts` or `.law/bin/verify-adapters` skipped, bypassed with `|| true`, or run with `--no-verify`
- a second skill authored with a near-duplicate description of an existing skill instead of amending the existing `description`
- the author claims "the runtime loads dynamically" without a dated research URL backing that claim

## Machine-readable contract

Primary: `.law/contracts/doc-taxonomy.contract.json` (fields: `layers[]` — the `skill` layer, once Unit 15 declares it, governs where skill files live; `classification_directives.on_new_doc`; `rules.unclassified_docs_forbidden`).

Cross-reference:

- `.law/contracts/project.contract.json#adapters` — skills are adapter-class projections per CONSTITUTION.md §3
- `.law/contracts/domain-map.contract.json` — Layer B skills are named after domains declared here; a Layer B skill whose target domain is absent from this contract is ill-grounded
- `.law/contracts/truth-owners.contract.json` — Layer B skill bodies reference the truth entries owned by the target domain
- `.law/charters/<domain>.md` — Layer B skills cite the domain's charter sections
- `.law/doctrine/agent-behavior.md` — research-freshness rule and known-failure-modes table
- `.law/adapters.md` — adapter-class projection policy; skills inherit the non-destructive patching discipline

Pressure-test envelope: `.law/context/research/authoring-project-skills-<YYYY-MM-DD>.json` records `(runtime_spec_urls[], without_skill_scenario, without_skill_behavior, with_skill_scenario, with_skill_behavior, fired: bool, bit: bool, shipped: bool)`. A skill lacking this envelope ships defective.

Runtime path: determined by live research per session; the kit's canonical copy lives at `.law/skills/<name>/SKILL.md` and the runtime-discoverable copy lives at the path the current runtime loads (commonly `.claude/skills/<name>/SKILL.md` as of 2026-04 — verify with dated URL before authoring).

Constitution anchors: CONSTITUTION.md §3 (Authority — adapters are non-authoritative projections; skills are adapter-class), §9 (Mutation rules — contract-vs-skill conflicts are resolved by amending the contract first, never by shipping a contradicting skill), §10 (Agent failure model — "Skipping research" and "Overfitting to familiar patterns" both apply to skill authoring).
