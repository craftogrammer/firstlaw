# Skill Template

Reference for authoring Layer A and Layer B skills. Pair with `.law/skills/authoring-project-skills/SKILL.md` (discipline + triggers) and `.law/doctrine/agent-behavior.md` (research-freshness, known failure modes).

---

## 1. Scaffold (copy-paste starting point)

```
---
name: <skill-name>
description: Use when <concrete triggering symptoms — nouns, verbs, artifacts, moments; no workflow summary>. Anchors: CONSTITUTION.md §<n>, §<n>.
---

# <Skill Name>

## Overview
Core principle in 1-2 sentences. Cite CONSTITUTION § anchor and the contract(s) this skill grounds in.

## When to Use
- Triggering symptom (concrete observable agent action)
- Another triggering symptom
- When NOT to use (the near-miss the load gate must refuse)

## Rule
One-sentence binding rule. Copy from the CONSTITUTION article or contract clause this skill projects.

## Agent must
- imperative bullet
- imperative bullet
- imperative bullet
- imperative bullet
- imperative bullet

## Agent must not
- prohibition
- prohibition
- prohibition

## Rationalizations — STOP and re-read
| Excuse | Reality |
|---|---|
| "..." | "..." |
| "..." | "..." |

## Red flags
- "I am thinking ..."
- "I am about to ..."

## Machine-readable contract
Primary: `.law/contracts/<contract>.contract.json` (fields: `<field>`, `<field>`).
Cross-reference: `.law/charters/<domain>.md`, `.law/contracts/truth-owners.contract.json`.
```

---

## 2. Layer A vs Layer B classifier

**Layer A — kit-universal.** Ships inside the firstlaw kit. Enforces a `CONSTITUTION.md` article. Scope is every project the kit is installed into. Examples: `checking-dep-edges-before-importing` (§5 dependency rules), `consulting-contracts-before-acting` (§3 authority). Naming: imperative gerund `<verb>ing-<object>-before-<moment>`.

**Layer B — project-specific.** Lives in a single project. Enforces a domain declared in `.law/contracts/domain-map.contract.json` and bound to that domain's charter plus `truth-owners.contract.json` entry. Scope is the declared domain boundary. Examples: `validating-payment-amounts-before-persistence`, `resolving-tenant-before-query`. Naming: same imperative-gerund shape as Layer A. Never `working-in-<domain>`, `helper-for-<domain>`, `<domain>-utilities`, `<domain>-guide`, or the bare domain name.

**Classifier rule.** A skill that fits neither class is ill-conceived. Halt authoring and surface to the user: either amend `CONSTITUTION.md` (promote to Layer A) or declare the missing domain in `domain-map.contract.json` (ground Layer B).

**Anchoring.** Layer A cites CONSTITUTION articles by number. Layer B cites the domain's charter section plus the `truth-owners.contract.json` entry. Both cite contract paths for every rule.

---

## 3. Research envelope JSON shape

Write one envelope per authored skill under `.law/context/research/<skill-name>-<YYYY-MM-DD>.json`. Records live research on the runtime's skill-format spec and the pressure-test outcome.

```json
{
  "skill": "<skill-name>",
  "authored_at": "2026-04-19",
  "runtime_target": {
    "id": "claude-code",
    "source": ".law/contracts/agent-runtime.contract.json#runtimes[?id='claude-code']",
    "retrieved_at": "2026-04-19"
  },
  "sources": [
    {"url": "https://...", "retrieved_at": "2026-04-19", "claim": "<what this URL anchors>"}
  ],
  "pressure_test": {
    "baseline_expected_behavior": "<what an agent without the skill would naturally do — name the exact code path, SQL, or decision>",
    "with_skill_expected_behavior": "<what this skill forces the agent to do instead — name the exact code path, SQL, or decision>",
    "subagent_dispatched": false,
    "fallback_rationale": "Single-agent session; thought experiment only.",
    "fired": true,
    "bit": true,
    "shipped": true
  }
}
```

A skill lacking this envelope ships defective (§10 rejects training-only authoring).

---

## 4. Pressure-test procedure

**Two-subagent protocol (preferred).**
1. Dispatch subagent #1 with project contracts loaded, skill NOT loaded. Present the scenario the skill must fire on. Record the envelope: what the agent did, which artifact it produced, which rationalization it used.
2. Dispatch subagent #2 identical to #1 except the skill IS loaded. Present the same scenario. Record the envelope.
3. Confirm the skill both **fires** (loaded on the matching symptom — the description gate triggered) and **bites** (followed the body's rules — refused the rationalization, halted, or routed correctly).
4. If fire or bite fails, the skill is broken. Do not commit. Fix the description (for fire) or tighten the body (for bite).

**Single-agent fallback.** When subagent dispatch is unavailable, document the expected before/after explicitly in the envelope's `pressure_test` object. Both `baseline_expected_behavior` and `with_skill_expected_behavior` MUST be concrete — name the exact code path, SQL query, decision branch, or commit artifact the skill bites on. Handwaving ("the agent would behave correctly", "it would do the right thing") fails the pressure test. The skill is not shipped.

**Example concrete bite points.**
- "Agent would type `import { db } from '../billing/db'` in `auth/session.ts`; skill forces halt because dep-graph marks `auth → billing` as cross-boundary."
- "Agent would write `WHERE tenant_id = ?` without binding tenant from session context; skill forces `resolveTenant()` call first."

---

## 5. Voice rules (short reference)

**Forbidden verbs (body + frontmatter).** `should`, `try to`, `consider`, `prefer`, `usually`, `generally`, `might`, `may want to`, `it is recommended`. These leak enforcement and SKIP BITE. Acceptable only inside a verbatim quoted excuse in the Rationalizations table.

**Imperative replacements.** `must`, `halt`, `refuse`, `reject`, `block`, `fire`, `cite`, `record`, `dispatch`, `surface`, `amend`, `re-read`.

**§ citations.** Every rule, must, and must-not anchors to a `CONSTITUTION.md §<n>` article or a `.law/contracts/<name>.contract.json#<field>` path. Assertions without an anchor are removed before commit.

**Backticks.** Wrap every path, frontmatter key, CLI command, variable, and JSON field in backticks. Unbacked paths fail voice review.

**Frontmatter description cap.** ≤ 500 chars. Three or more distinct concrete triggers. Each trigger names an observable agent action, not a workflow category.

**Body cap.** Aim for ≤ 80 body lines. Long how-to extracts into this template; the skill body stays focused on discipline.
