# Product doctrine

> **Layer:** doctrine · **Authority:** elaboration · **Mutability:** timeless until amended
> Elaborates the principles behind `CONSTITUTION.md` and `.law/contracts/project.contract.json`. Must not contradict either.

## Role of this document

Defines the shape of **product truth**. The `product` subagent populates `project.contract.json#identity` and may amend this file; projects amend deliberately thereafter. Not a roadmap, not a feature list, not marketing.

## What a product definition must answer

### 1. Core statement

One sentence. Subject, verb, user, outcome. No adjectives without weight.

Shape: *"This product lets `<primary user>` accomplish `<specific outcome>` under `<specific constraint>`."*

A product that cannot produce this sentence has no identity. Features accumulate; identity does not.

### 2. Primary user

Who this product serves, precisely. Not "everyone." Not "developers." A concrete archetype with context: what they do when this product is absent, what they use today, where they hit friction.

### 3. Non-users

Who this product does **not** serve. Naming non-users bears load. It blocks accidental feature drift.

### 4. Anti-goals

Explicit list. Each anti-goal names a thing the product will not do, paired with the reason — usually because doing it would compromise the primary user's outcome or breach a boundary.

An anti-goal without a reason is a preference. An anti-goal with a reason is a commitment.

### 5. Non-negotiables

Properties that must hold regardless of feature decisions. Shape examples, not content:

- "no data leaves the device"
- "no synchronous calls on the hot path"
- "every user action is undoable"

Non-negotiables are load-bearing walls. Changing them is a constitutional amendment, not a tweak.

### 6. Current product posture

One paragraph: what the product does today, what it refuses today, and the nearest adjacent problems it deliberately declines.

## Rules for product doctrine

- no marketing language
- no aspirational statements without a commitment mechanism
- no "we believe" — either a belief produced a decision, in which case declare the decision, or it did not, in which case it is not doctrine
- no feature lists

## How this doctrine is used

Agents consult this before proposing any scope-relevant work. Agents refuse requests that contradict an anti-goal absent a recorded amendment. Agents under pressure to soften an anti-goal must escalate, not soften.

## Pointer

Machine-readable identity lives in `.law/contracts/project.contract.json#identity`. This doctrine is the prose counterpart; the contract is authoritative.
