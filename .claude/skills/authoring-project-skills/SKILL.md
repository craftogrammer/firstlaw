---
name: authoring-project-skills
description: Use when a recurring workflow gap surfaces across sessions ("we keep tripping on X"); when a new agent failure mode has no Layer B skill covering it; when the user says "write me a skill for Y" or "codify this"; when a domain in `domain-map.contract.json` has a charter but no matching skill and errors recur; when a contract amendment shifts the cognitive moment at a domain boundary; when a pressure-test shows an existing skill no longer fires. Anchors: CONSTITUTION.md §3, §9, §10.
---

# Authoring Project Skills

## Overview
A project skill is an adapter-class projection (CONSTITUTION.md §3) that loads into a runtime and alters agent behavior at a specific cognitive moment. Skills are non-authoritative: repo law lives in `CONSTITUTION.md` and `.law/contracts/*`, and a skill is defective the instant it contradicts a contract. **Layer A** is kit-universal (enforces a CONSTITUTION article); **Layer B** is project-specific (enforces a domain in `.law/contracts/domain-map.contract.json`). See `.law/templates/skill-template.md` § 1–5 for scaffold, Layer A/B classifier, research envelope shape, pressure-test procedure, and voice rules. Two failure modes govern every skill: **MISSED LOAD** (description fails to fire on the real symptom) and **SKIPPED ENFORCEMENT** (skill loads but the agent routes around the body). The body below forbids both.

## When to Use
Fire the instant any of the following holds:
- the same agent rationalization appears in two or more sessions on this repo
- a newly-observed agent failure mode has no existing Layer B skill covering its cognitive moment
- the user requests a new skill: "write me a skill for Y", "codify this", "we keep tripping on X"
- a domain in `.law/contracts/domain-map.contract.json` has a charter and a `truth-owners.contract.json` entry but no matching Layer B skill, and recent sessions show domain-boundary errors
- a contract amendment shifts the cognitive moment an agent faces (new ambiguity policy, new dep-edge category, new truth-owner class)
- a pressure-test of an existing skill shows it no longer fires on its declared symptoms
- a skill shipped in this repo has no pressure-test envelope under `.law/context/research/`
- Do NOT fire to re-skin an existing skill whose description almost matches — amend the existing description instead

## Rule
Classify the cognitive moment (Layer A vs Layer B), research the current runtime skill-format spec with dated URLs, ground every line in a contract or charter anchor, pressure-test both load (fire) and enforcement (bite) before commit, and surface a single reload line at end-of-session.

## Agent must
- classify Layer A vs Layer B before authoring; halt and surface if the skill fits neither (see `.law/templates/skill-template.md` § 2)
- perform live web research on the target runtime's current skill-format spec and record dated retrieval URLs under `.law/context/research/<skill-name>-<YYYY-MM-DD>.json` using the envelope shape in `.law/templates/skill-template.md` § 3
- ground Layer B skill bodies in the domain's charter plus `truth-owners.contract.json` entry, and cross-link both paths in the body
- name Layer B skills after the cognitive moment (`validating-X-before-Y`, `resolving-X-before-Z`) — never `working-in-<domain>`, `helper-for-<domain>`, `<domain>-utilities`, `<domain>-guide`, or the bare domain name
- write the frontmatter description as the load gate: three or more distinct concrete triggers, each naming an observable agent action
- write the body using the scaffold in `.law/templates/skill-template.md` § 1 (Overview, When to Use, Rule, Agent must, Agent must not, Rationalizations, Red flags, Machine-readable contract) in imperative voice, citing `CONSTITUTION.md` articles and contract paths
- pressure-test per `.law/templates/skill-template.md` § 4 — two-subagent protocol preferred, single-agent fallback only with concrete before/after in the envelope
- refuse to ship unless the envelope shows the skill both fires on the matching symptom and bites when loaded
- surface `Skill \`<name>\` committed to \`<path>\`. Reload your agent runtime for it to become discoverable.` at end-of-session
- run `.law/bin/validate-contracts` and `.law/bin/verify-adapters` and block on non-zero exit

## Agent must not
- compile a skill programmatically from a contract — authoring requires judgment and live research, not schema projection
- author from training recall alone, skipping the dated-URL research step (§10 rejects training-only claims on current-state questions)
- ship a skill whose body encodes project law that belongs in a contract (§3 forbids law in adapter-class files)
- ship a skill without the pressure-test envelope (fire + bite) recorded under `.law/context/research/`
- claim the skill is active in the current session without consulting `.law/contracts/agent-runtime.contract.json` for the runtime's load model
- drop the reload line at end-of-session or soften it into a question
- commit a skill that contradicts an existing charter, contract, or constitution article — amend the conflicting layer first per §9
- use softening verbs (`should`, `try to`, `consider`, `prefer`, `usually`, `generally`, `might`) anywhere in the body
- author a new skill when the correct action is amending an existing skill's description to fire on the missed symptom
- defer the pressure-test "until the next session" — an unvalidated skill silently rots
- bypass `.law/bin/validate-contracts` or `.law/bin/verify-adapters` with `|| true`, `--no-verify`, or silent skip

## Rationalizations — STOP and re-read
| Rationalization the agent whispers | Why it is still forbidden |
|---|---|
| "I know the skill format cold from training." | §10: skipping research is a named failure mode. The format spec moves; 2024 recall fails a 2026 author. Fetch dated URLs. |
| "I'll ship now and pressure-test later." | An unvalidated skill MISSES LOAD or SKIPS ENFORCEMENT silently. Both failure modes defeat the point. Pressure-test before commit. |
| "The runtime picks up skills automatically — no reload needed." | Load models differ per runtime. Consult `.law/contracts/agent-runtime.contract.json`. Claude Code 2026-04 hot-reloads file edits in existing skill directories; new directories still require session restart. Cursor reloads rules at session start. Codex: unknown (requires live research). Surface the reload line unless the runtime contract declares live-edit detection for the change class. |
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
Halt and re-check if any appear:
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
Scaffold, Layer A/B classifier, research-envelope shape, pressure-test procedure, voice rules: `.law/templates/skill-template.md` § 1–5. Contracts: `.law/contracts/doc-taxonomy.contract.json` (skill layer, classification), `.law/contracts/project.contract.json#adapters` (§3 adapter class), `.law/contracts/domain-map.contract.json` (Layer B naming targets), `.law/contracts/truth-owners.contract.json` (Layer B body anchors), `.law/contracts/agent-runtime.contract.json` (runtime load model + discovery path), `.law/charters/<domain>.md` (Layer B charter anchor), `.law/doctrine/agent-behavior.md` (research-freshness, failure modes), `.law/adapters.md` (adapter policy). Constitution: §3 (adapters non-authoritative), §9 (amend contract before shipping a contradicting skill), §10 (skipping research + overfitting).
