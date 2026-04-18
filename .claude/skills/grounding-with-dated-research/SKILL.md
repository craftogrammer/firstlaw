---
name: grounding-with-dated-research
description: Use when about to claim anything about an architecture pattern, library choice, dependency quality, framework behavior, API surface, CLI tool usage, cloud service, version compatibility, or security posture; when about to answer "what is the best way to...", "what does library X support...", "is package Y safe...", "which version of Z..."; when recommending, selecting, or comparing technologies; when stamping any contract field that records provenance (e.g. `generated_from`, `last_validated_at`).
---

# Grounding With Dated Research

## Overview

CONSTITUTION §10 names "Skipping research" as a predictable agent failure mode. The kit's model cutoff trails reality by months. Training-era recall about versions, APIs, dep quality, and architecture patterns is wrong more often than right. Any such claim must rest on live web research with a retrieval date in `YYYY-MM-DD` form, the source URL recorded next to the claim, and an explicit `evidence` or `judgment` label. Training-only recall is not evidence.

## When to Use

Fire this skill the moment the agent is about to:

- recommend or compare a library, framework, SDK, runtime, package manager, or cloud service
- state what version X supports, requires, deprecates, or breaks
- describe the API surface, CLI flags, configuration schema, or default behavior of an external tool
- assess a dependency's quality, maintenance status, license, or security posture
- answer "what is the best way to...", "which library does X...", "is package Y safe...", "does Z still support..."
- stamp `generated_from`, `last_validated_at`, or any other provenance field in a contract under `.law/contracts/`
- write or amend doctrine, charter, or contract prose that references external technology state

## Rule

Halt before the claim. Retrieve live sources. Record retrieval date in `YYYY-MM-DD` form and the source URL beside the claim. Label the claim `evidence` (observed in a dated retrieval) or `judgment` (inferred from evidence). Refuse to emit the claim until the retrieval date, the URL, and the label exist in the output.

**Anchor:** CONSTITUTION §10 — Agent failure model, "Skipping research".
**Doctrine:** `.law/doctrine/agent-behavior.md` — "Research freshness (hard rule)".

## Agent must

- halt on any claim listed in "When to Use" and retrieve live sources before proceeding
- record the retrieval date in `YYYY-MM-DD` form next to the claim
- record the source URL next to the claim
- label every non-trivial external claim `evidence` or `judgment`
- route library and framework questions through the project's designated doc retrieval path first (for example `context7` where available, official vendor docs otherwise) and record the tool used
- deposit the research log at `.law/context/research/<subagent>-<YYYY-MM-DD>.json` when operating as a subagent
- consult `.law/doctrine/agent-behavior.md` "Research freshness" before finalizing any contract field
- register the retrieval in `generated_from` when the claim lands in a contract
- amend or replace a prior claim whose retrieval date has aged past the project's freshness window
- declare `judgment` explicitly and surface it as a hypothesis, never as evidence
- block the response and surface the gap when a source cannot be retrieved

## Agent must not

- emit a version number, API name, CLI flag, config key, or compatibility claim from training recall alone
- substitute "I recall that..." or "typically..." for a dated retrieval
- paraphrase a source without recording its URL and retrieval date
- stamp `last_validated_at` or `generated_from.run_at` without performing the retrieval that date claims
- treat a prior session's research as fresh in the current session unless its date falls inside the project's freshness window
- collapse multiple sources into one citation
- promote a `judgment` label to `evidence` by rewording
- skip research because the question "feels small"
- present cached training knowledge as equivalent to a dated source

## Rationalizations — STOP and re-read

- "I know this one cold." — training data rots silently on versions, APIs, and defaults. Retrieve.
- "The docs haven't changed in years." — verify that with a dated retrieval, then cite it. An assumption of stability is not evidence of stability.
- "This is a small detail, no need to source it." — small details are where version mismatches and deprecations hide. Retrieve.
- "I already researched similar stuff last session." — a prior session's retrieval does not carry forward. Re-retrieve or cite the prior log by path and date.
- "This is a syntax question, training data is fine." — syntax drifts across major versions. Retrieve against the version in play.
- "Retrieving takes too long for a quick answer." — the research-freshness rule is hard, not soft. A slow correct answer beats a fast wrong one. Retrieve.
- "The user will correct me if I'm wrong." — outsourcing verification to the user violates §10. Retrieve.
- "I will add the citation later." — later never arrives. Retrieve now or halt.

## Red flags

If any of these appear in the draft response, halt and retrieve:

- a version number without a URL and retrieval date
- a package name with a quality or safety claim and no source
- "as of my knowledge..." or "as of my training..."
- hedging adverbs (`typical`, `usual`, `general`) attached to external-tool behavior
- "the latest version of X..." without a dated retrieval
- `last_validated_at` or `generated_from.run_at` stamped in the same diff as a claim with no recorded retrieval
- a contract amendment touching external-tool state with no URL in the commit context
- a recommendation phrased as "X is the standard" with no dated source
- paraphrased API behavior with no link to the vendor's current documentation

## Machine-readable contract

This skill is cross-cutting discipline and binds no single contract schema. The binding law lives one layer above skills:

- **CONSTITUTION §10** — "Skipping research" failure mode; live web research with retrieval dates is required on architecture, library, and dep-quality claims; training-only claims are rejected.
- **`.law/doctrine/agent-behavior.md`** — "Research freshness (hard rule)" and the `evidence` vs `judgment` labeling requirement. Doctrine sits directly below contracts in CONSTITUTION §1 precedence and binds all agent behavior.

Fields this skill writes into across the contract layer:

- `generated_from` on any contract the retrieval grounds (records tool, run timestamp, and provenance)
- `generated_from.run_at` (the retrieval timestamp, in the date form this skill enforces)
- `last_validated_at` on any contract stamped as part of the same change
- `evidence_or_judgment` on every contract entry the claim populates

Research-log deposit path (consumed by later audits, never by the orchestrator's working context):

- `.law/context/research/<subagent>-<YYYY-MM-DD>.json`

On any conflict between this skill and the constitution or a contract, the higher layer wins. Amend the higher layer or block the task — never soften the rule silently.
