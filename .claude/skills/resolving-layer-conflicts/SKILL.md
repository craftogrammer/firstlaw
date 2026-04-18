---
name: resolving-layer-conflicts
description: Use when a lower authority layer contradicts a higher one — a charter claims ownership the truth-owners contract does not grant, a doctrine bullet softens a CONSTITUTION must-not, an adapter file encodes a rule the contracts do not declare, a plan cites a dependency edge not in `dependency-rules.contract.json`, a context snapshot disagrees with a charter, or runtime code behaves differently from what doctrine declares.
---

# Resolving Layer Conflicts

## Overview

CONSTITUTION.md §1 fixes the precedence ladder: `CONSTITUTION.md` → `.law/contracts/*.contract.json` → `.law/doctrine/*.md` and `.law/charters/*.md` → `.law/context/*` → tool-facing adapter files. The higher layer wins on any conflict. Runtime truth is evidence, not a layer; reconcile it explicitly against the layer that describes it. This skill fires the moment a contradiction between layers surfaces.

## When to Use

Fire this skill on any of these triggers:

- A `.law/charters/<domain>.md` claims ownership that `.law/contracts/truth-owners.contract.json` does not grant.
- A `.law/doctrine/*.md` bullet softens, qualifies, or narrows a CONSTITUTION `must` or `must not`.
- An adapter file (`CLAUDE.md`, `AGENTS.md`, `codex.md`, `.cursorrules`, `.github/copilot-instructions.md`) encodes a rule `CONSTITUTION.md` and `.law/contracts/*.contract.json` do not declare.
- A plan file cites a dependency edge absent from `.law/contracts/dependency-rules.contract.json#allowed`.
- A `.law/context/*` snapshot contradicts a charter or a contract.
- Runtime code behaves differently from what a charter, doctrine file, or contract declares.
- Two lower-layer files disagree with each other and both disagree with the layer above them.

## Rule

Halt the in-flight task the moment the contradiction surfaces. Consult CONSTITUTION.md §1 and `.law/KIT_INDEX.md` to re-identify which layer is higher. Record the contradiction in `.law/context/current-system.json#contradiction_map`. Either amend the lower layer to match the higher layer, or flag the higher layer for amendment via the authority listed in CONSTITUTION.md §0 — never both, never simultaneously, never silently. Runtime truth enters as evidence under the matching `evidence_or_judgment` field; reconcile it against the layer that describes it through the same single-direction amendment path.

## Agent must

- halt the in-flight task on first notice of any trigger in "When to Use"
- re-read CONSTITUTION.md §1 and identify the higher and lower layer by name before proposing any change
- record the contradiction in `.law/context/current-system.json#contradiction_map` with `path`, `observed_at`, `higher_layer`, `lower_layer`, and `evidence_or_judgment`
- pick exactly one direction — amend the lower layer to match the higher, or flag the higher layer for amendment through the authority in CONSTITUTION.md §0
- surface the chosen direction to the user before editing either file
- amend the matching contract in `.law/contracts/*.contract.json` in the same change per CONSTITUTION.md §9 when the direction crosses contract boundaries
- delete an adapter-encoded rule that has no contract home, then register the adapter patch in `.law/contracts/project.contract.json#adapters.patched_files[]`
- label runtime observations as `evidence` and reconcile them against the layer that describes them through the same single-direction amendment path
- escalate to the amendment authority named in CONSTITUTION.md §0 when the higher layer is the one that must change
- block the task until the contradiction is resolved per CONSTITUTION.md §11

## Agent must not

- edit both the higher and the lower layer in one change to make them agree
- silently reconcile by preferring the newer file, the file closest to runtime, or the file the user last touched
- treat runtime code as authoritative over a charter, doctrine, or contract
- promote a `.law/context/*` snapshot to truth to end the conflict
- encode project law inside an adapter file to paper over a contract gap — CONSTITUTION.md §3 forbids it
- soften a contract, charter, or doctrine bullet to match drifted code; amend one side, never both
- defer the reconciliation with a `TODO` comment — CONSTITUTION.md §11 forbids it
- wrap the contradiction in an abstraction, a flag, or a parallel logic path to hide it

## Rationalizations — STOP and re-read

Close each of these before proceeding:

- "The doctrine is more up to date than the contract, trust doctrine." Refuse. The contract is higher per CONSTITUTION.md §1. Amend the doctrine to match the contract, or flag the contract for amendment — never both.
- "The adapter is what users actually read, so it wins in practice." Refuse. Adapters are non-authoritative projections per CONSTITUTION.md §3. The adapter is defective; delete the rule or push it into a contract first.
- "The code is what ships, that's the truth." Refuse. Runtime truth is evidence, not a layer. CONSTITUTION.md §1 names it explicitly. Reconcile code against the layer that describes it through a single-direction amendment.
- "We will patch both sides to match and keep moving." Refuse. CONSTITUTION.md §10 forbids softening rules to fit the current mess and forbids doing both silently. Pick one side, surface the choice, record the amendment.
- "This is a minor wording difference." Refuse. Ambiguity class `rule softness` in CONSTITUTION.md §7 halts on exactly that signal. Record it, apply `.law/contracts/ambiguity-policies.contract.json`, amend one side.
- "The charter was written by the domain owner, so it wins over the generic contract." Refuse. `.law/contracts/truth-owners.contract.json` is higher than any charter per CONSTITUTION.md §1. Amend the charter, or flag the contract for amendment through the authority.
- "The plan is already approved; update the contract to match the plan." Refuse. Plans are `temporary-plan` per CONSTITUTION.md §4; contracts are higher. Amend the plan, or halt the plan and flag the contract for amendment.

## Red flags

Halt immediately when any of these appear in your own reasoning or in a diff:

- phrases like "reconcile both", "align the docs", "sync them up", "make them match" without naming a single direction
- a diff that edits a contract and a doctrine file and an adapter in one change to make them agree
- a commit message that reads "fix drift" without naming `higher_layer` and `lower_layer`
- a proposal to "update the contract to match what the code does" without an amendment authority sign-off
- a new rule appearing only in an adapter, with no corresponding contract field
- a `.law/context/*` snapshot edited to end a disagreement with a charter
- a plan that cites a dependency edge, directory owner, or truth owner that no contract declares
- the verbs "reconcile", "resolve", "harmonize", "align" used without the word "amend" next to them

## Machine-readable contract

Authority anchor: `CONSTITUTION.md` §1 (Precedence), §9 (Mutation rules), §11 (Enforcement).

Primary contracts consulted:

- `.law/contracts/project.contract.json` — `adapters.patched_files[]`, `pointers`, amendment authority surface
- `.law/contracts/truth-owners.contract.json` — owning domain for any contested truth
- `.law/contracts/dependency-rules.contract.json` — declared edges; absence = forbidden
- `.law/contracts/doc-taxonomy.contract.json` — layer classification of every document in the diff
- `.law/contracts/ambiguity-policies.contract.json` — matching policy for the observed contradiction class

Observation record (append to `.law/context/current-system.json#contradiction_map`):

```json
{
  "path": "<file that carries the lower-layer statement>",
  "observed_at": "<ISO-8601 timestamp>",
  "higher_layer": "constitution | contract | doctrine | charter | context-snapshot | adapter",
  "lower_layer": "constitution | contract | doctrine | charter | context-snapshot | adapter",
  "contradiction": "<one-line statement of the disagreement>",
  "evidence_or_judgment": "evidence | judgment",
  "chosen_direction": "amend_lower | flag_higher_for_amendment",
  "amendment_ref": "<commit sha or pending-question id>"
}
```

Resolution gates:

- `chosen_direction` holds exactly one value per entry
- `amend_lower` edits only the lower-layer file and any contract required by CONSTITUTION.md §9
- `flag_higher_for_amendment` creates an entry in `.law/context/pending-questions.json` addressed to the amendment authority named in CONSTITUTION.md §0 and blocks the task per §11
- the entry closes only when the amendment lands and `last_validated_at` on every touched contract is stamped
