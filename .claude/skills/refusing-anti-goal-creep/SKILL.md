---
name: refusing-anti-goal-creep
description: Use when a user says "can we also...", "it would be nice if...", "while we're at it...", "since we're already here...", "everyone expects X", "that's a natural extension", "this is basically part of the original scope", or "the anti-goal was written before we knew X"; when a feature idea, adjacent improvement, or dependency pulled in for a new use case edges past `project.contract.json#identity.purpose_one_line`; when a request brushes any item declared in `identity.anti_goals`; when an agent catches itself drafting code that implements a forbidden thing quietly; when scope expands sideways into adjacent problem spaces without an amendment.
---

# Refusing Anti-Goal Creep

## Overview

Anti-goals are hard stops declared in `project.contract.json#identity.anti_goals`. CONSTITUTION §2 binds every agent to treat them as such. This skill fires the instant a request, idea, or dependency edges past `identity.purpose_one_line` or brushes an anti-goal. Halt the task, surface the drift, refuse to implement, and route the user toward an amendment of `project.contract.json` as the only legitimate path to change.

## When to Use

Load this skill when any of the following fire:

- A user request contains "can we also...", "it would be nice if...", "while we're at it...", "since we're already here...", "everyone expects X", or "that's a natural extension".
- A feature idea, adjacent improvement, or "fold it in and refactor later" suggestion reaches outside `identity.purpose_one_line`.
- A dependency is pulled in for a use case not covered by the declared purpose.
- A request brushes, softens, or reinterprets an item in `identity.anti_goals`.
- An agent notices itself drafting code that implements a forbidden thing before surfacing the conflict.

## Rule

CONSTITUTION §2 binds the agent: `anti_goals` are hard stops, and the purpose is the outer boundary of scope. Refuse every request that contradicts `identity.purpose_one_line` or any `identity.anti_goals` item absent a recorded amendment. Surface identity drift the moment a request edges past declared scope. Implementation without amendment of `project.contract.json` is forbidden.

## Agent must

- halt the in-flight task the instant a request brushes `identity.anti_goals` or edges past `identity.purpose_one_line`
- re-read `.law/contracts/project.contract.json#identity` and quote the exact `purpose_one_line` and the matching anti-goal verbatim to the user
- refuse to implement the forbidden change, even partially, even behind a feature flag, even as a prototype
- surface the drift loudly: name the request, name the anti-goal it brushes, name the field it contradicts
- route the user to the amendment path: edit `project.contract.json#identity` plus the CONSTITUTION amendment log per §9, then proceed
- record the observation in `.law/context/current-system.json#contradiction_map` when the drift surfaces mid-task
- escalate to the amendment authority named in `project.contract.json` when the user pushes past refusal

## Agent must not

- expand scope because a feature "seems natural" or "users expect it"
- soften `identity.anti_goals` language because the user asked nicely, pushed back, or cited urgency
- fold the forbidden change into an adjacent ticket, refactor, or cleanup commit
- ship behind a flag, in a branch, or as a "prototype" while the anti-goal still stands
- treat the anti-goal as stale because it was written before the current request existed
- accept the user's reinterpretation of `purpose_one_line` as authoritative — the contract is authoritative
- resolve the conflict silently by narrowing the anti-goal's scope in prose without amending the contract
- defer the refusal with a `TODO` or a "follow-up" note

## Rationalizations — STOP and re-read

When any of these sentences surface in an agent's chain of thought, halt and re-read CONSTITUTION §2:

- "The user asked nicely and this is a small addition." Anti-goals do not bend to tone.
- "This is basically part of the original scope." If it were, `purpose_one_line` would cover it. It does not.
- "It is only a small tangent — we can fold it in and refactor later." Folding a forbidden edge in is the violation; refactor-later is how creep becomes architecture.
- "The anti-goal was written before we knew X." New knowledge triggers an amendment per §9, not a silent bypass.
- "Everyone expects this feature." The contract declares what this product does, not what an imagined everyone expects.
- "A prototype does not count." Runtime truth counts the moment it exists; §2 does not carve out prototypes.
- "The user is the amendment authority, so the request itself is the amendment." An amendment is a recorded change to `project.contract.json` and a row in the CONSTITUTION amendment log. A chat message is not.
- "I can implement it in a feature branch and decide later." Branches ship. Deciding later is deferring the decision while paying the cost.

## Red flags

Halt the task when any of these appear:

- a diff that adds code a reasonable reader would label under an `identity.anti_goals` item
- a new dependency whose declared purpose overlaps a forbidden use case
- a commit message containing "while we're at it", "since we're here", "natural extension", or "small addition"
- a prose update that narrows an anti-goal's language without a matching CONSTITUTION amendment-log row
- a "prototype", "spike", or "experiment" implementing the forbidden thing
- a feature flag gating the forbidden thing behind "off by default"
- an adapter file (`CLAUDE.md`, `AGENTS.md`, etc.) edited to soften or reframe an anti-goal — adapters hold no authority per §3
- the user citing urgency, customer demand, or competitive pressure as grounds to bypass the contract

## Machine-readable contract

- CONSTITUTION anchor: §2 (Identity)
- Primary contract: `.law/contracts/project.contract.json`
- Bound fields: `identity.purpose_one_line`, `identity.anti_goals`
- Amendment path: edit `project.contract.json#identity`, record a row in the CONSTITUTION amendment log per §9, commit atomically with the change that motivated it
- Escalation target: `project.contract.json` amendment authority
- Drift log: `.law/context/current-system.json#contradiction_map`
