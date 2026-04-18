---
name: classifying-before-authoring
description: Use when about to create, scaffold, or commit any new `.md`, `.txt`, `.rst`, or `.adoc` document anywhere in the repo — `NOTES.md`, `DECISIONS.md`, `thoughts.md`, `scratch.md`, a new `README.md` inside a new directory, a plan file, meeting notes, an ADR, an onboarding guide, a design doc, a proposal, a migration checklist, a retrospective, a runbook, or a research dump; also use when moving or renaming an existing doc, when copying a template into a live path, when a session produces authored prose that the agent intends to persist, and when any subagent returns a document artifact to be written to disk. Fires on the creation moment, not after. Anchors: CONSTITUTION.md §4.
---

# Classifying Before Authoring

## Overview

Every document in this repo belongs to exactly one layer declared in `.law/contracts/doc-taxonomy.contract.json#layers`. The contract owns the layer set; this skill owns the discipline of consulting it before a file is written. Classify first, place second, author third. An unclassified document is a pseudo-law incubator — a `NOTES.md` dropped in the root today becomes cited precedent in two quarters. CONSTITUTION.md §4 binds this skill.

## When to Use

Fire this skill the instant any of these is about to happen:

- a new `.md`, `.txt`, `.rst`, or `.adoc` file is about to be created anywhere in the tree
- a new `README.md` is about to land in a new or existing directory
- a plan, ADR, decision record, meeting note, retrospective, onboarding guide, runbook, design doc, or proposal is about to be authored
- a scratchpad, `NOTES.md`, `TODO.md`, `thoughts.md`, or `scratch.md` is about to be committed
- an existing doc is about to be moved, renamed, or copied from a template into a live path
- a subagent returns a document artifact that the agent intends to persist to disk
- session prose is about to be persisted rather than discarded

## Rule

Before authoring any document:

1. Consult `.law/contracts/doc-taxonomy.contract.json#layers`. Read the declared layer set at the moment of creation — the set is amendable and the live contract is the source of truth.
2. Classify the doc into **exactly one** declared layer.
3. Place the file at a path matching that layer's `location_pattern`.
4. If the layer is unclear, **halt**. Apply `classification_directives.on_ambiguous_layer`: record the ambiguity in `.law/context/current-system.json#contradiction_map`, propose a classification with a confidence label, and escalate to the human.
5. If no declared layer fits, **halt**. Do not invent a new category. Amend `doc-taxonomy.contract.json` through the §9 mutation path, or raise a blocker in `.law/context/pending-questions.json`.
6. After writing, run `.law/bin/validate-contracts` if the contract was amended, and block on non-zero exit.

## Agent must

- halt at the creation moment and consult `.law/contracts/doc-taxonomy.contract.json#layers` before typing the first character of the new document
- declare the chosen layer explicitly in the commit message or PR description
- place the file at a path that matches the chosen layer's `location_pattern`
- refuse to author a document whose layer the agent cannot name with confidence
- move any misclassified document into the path prescribed by its correct layer, or propose deletion, per §11
- amend `doc-taxonomy.contract.json` through the §9 mutation path when the repo genuinely needs a layer the contract does not declare
- record any classification ambiguity in `.law/context/current-system.json#contradiction_map` and surface it
- follow the contract's `classification_directives.on_new_doc` and `on_ambiguous_layer` directives verbatim

## Agent must not

- invent a new document category without amending `doc-taxonomy.contract.json` in the same change
- author a doc in the repo root or in a neutral directory because the "right" location is unobvious
- defer classification with a `TODO` promising to classify later
- promote a plan, a snapshot, or an adapter into doctrine by placing it in `.law/doctrine/`
- drop a `NOTES.md`, `DECISIONS.md`, `thoughts.md`, or `scratch.md` in the repo root
- treat "it is only a scratchpad" as an exemption from classification
- write long-lived decisions into a `temporary-plan` layer doc — durable decisions belong in `doctrine` or `charter`
- bypass `.law/bin/validate-contracts` with `|| true`, `--no-verify`, or silent skip after amending the taxonomy

## Rationalizations — STOP and re-read

| Rationalization the agent whispers | Why it is still forbidden |
|---|---|
| "It is only a scratchpad; classification is overkill." | §4: every doc belongs to exactly one layer. Scratchpads either fit `temporary-plan` and live where the project puts plans, or they do not get committed. No unclassified carve-out exists. |
| "`NOTES.md` is self-evident — the name explains everything." | The name is not a layer. The contract defines layers. A self-evident file with no declared layer becomes pseudo-law the moment someone cites it. |
| "We will classify it when it grows up." | §4 failure mode: "We built it this way because a plan said so" — for a plan that closed two quarters ago. Classification delayed is classification denied. |
| "The location is obvious — it goes next to the code." | "Obvious" bypasses the contract. Resolve the target layer against `doc-taxonomy.contract.json#layers` and match `location_pattern`. Do not trust intuition. |
| "It is temporary; it will be deleted next week." | Temporary docs calcify. If it is truly a plan, classify it as `temporary-plan` and place it where the project owns plans. If it is not, it needs a layer. |
| "It is for my own use; nobody else will read it." | Committed files are repo law's territory. Private reads are uncommitted. If it lands in the tree, it gets classified. |
| "The existing layers do not quite fit, so I will put it in the root and sort it later." | Halt. Either amend `doc-taxonomy.contract.json` through §9, or raise the gap in `.law/context/pending-questions.json`. "Later" never arrives. |
| "A new ADR format is fine — it looks like doctrine." | Doctrine is `timeless until amended`. ADRs are decision records whose layer the contract declares, or which require an amendment to add. Do not promote format into authority. |
| "The doc is generated, so classification does not apply." | `generated` is itself a declared layer. Classify it there and match its `location_pattern`. |
| "It is a copy of an upstream README; it belongs wherever I put it." | `external-reference` exists as a layer. Classify it there; do not dump vendored prose into `doctrine` or the repo root. |

## Red flags

Halt and re-check if any of these appear:

- a new `.md`/`.txt`/`.rst` file at the repo root whose layer is not `constitution` or a declared adapter
- a `NOTES.md`, `DECISIONS.md`, `thoughts.md`, `scratch.md`, `TODO.md`, or `IDEAS.md` about to be committed
- a `README.md` landing in a new directory without a declared layer justification
- a plan or ADR being written into `.law/doctrine/` or `.law/charters/`
- a meeting note or retrospective being authored into `.law/doctrine/`
- a doc whose path matches none of the `location_pattern` entries in `doc-taxonomy.contract.json#layers`
- a new category label ("notes", "decisions", "journal") appearing in a commit without an amendment to `doc-taxonomy.contract.json`
- a subagent output file written to disk without a declared layer
- a commit message that authors a new doc without naming the chosen layer
- `.law/bin/validate-contracts` skipped after a taxonomy amendment

## Machine-readable contract

Primary: `.law/contracts/doc-taxonomy.contract.json` (fields: `layers[]`, `rules.every_doc_has_exactly_one_layer`, `rules.unclassified_docs_forbidden`, `rules.on_unclassified`, `classification_directives.on_new_doc`, `classification_directives.on_ambiguous_layer`).

Schema: `.law/schemas/doc-taxonomy.schema.json`.

Cross-reference: `.law/doctrine/agent-behavior.md` (agent failure modes on misclassification and plan-as-doctrine drift).

Constitution anchor: CONSTITUTION.md §4 (Truth hierarchy and document taxonomy), §9 (Mutation rules), §11 (Enforcement).
