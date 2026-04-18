# Subagent contract: ambiguity

## 1. Identity

- **id:** `ambiguity`
- **goal:** Validate the standard ambiguity policies, add stack-specific policies when warranted, and seed `.law/context/current-system.json#contradiction_map` with any contradictions observable during bootstrap. Patch `ambiguity-policies.contract.json`.

## 2. Reads

- `project.contract.json` (stack, mode)
- `domain-map.contract.json` and `truth-owners.contract.json` (to reason about which ambiguity classes will matter)
- Pre-seeded standard policies in `ambiguity-policies.contract.json`
- Source tree — surface scan for obvious signals of each ambiguity class

## 3. Researches

For the detected stack, research stack-specific ambiguity classes worth codifying. Examples (not exhaustive, not hardcoded):

- Module resolution ambiguities (different bundlers, different import semantics)
- Config layering pitfalls in common frameworks
- ORM / state-store patterns that commonly produce shadow writers

Retrieval dates required for any web-sourced claim.

## 4. Elicits

- **Known rough spots** — parts of the codebase or domain the user already flags as ambiguous (non-blocking; seeds contradiction_map)
- **Preferred default action** — whether the project prefers `halt_and_escalate` or `proceed_with_judgment` when no policy matches (non-blocking; default is halt)

## 5. Produces

Patches:

- `ambiguity-policies.contract.json#policies` — add stack-specific policies, each with `evidence_or_judgment` label
- `ambiguity-policies.contract.json#rules.default_action_when_no_policy_matches` — confirm or change
- `.law/context/current-system.json#contradiction_map` — append any observed contradictions with evidence

## 6. Envelope

- `subagent_id`: `"ambiguity"`
- `decisions[]`: which standard policies apply, which stack-specific policies to add
- `evidence[]`: references for any observed contradiction (file paths, line ranges), web sources for stack-specific policies with retrieved_at
- `judgment[]`: proposed stack-specific policies that fall outside direct observation
- `questions_for_orchestrator[]`: policy choices the user must confirm
- `proposed_contract_patches[]`: patches to `ambiguity-policies.contract.json` and `.law/context/current-system.json`

## 7. Advisor checkpoints

- **Checkpoint A — before committing policy list**: consult advisor with the final list. Looking for: missing common-but-not-standard classes, actions too weak to enforce.
- **Checkpoint B — before finalizing envelope**: validate contradiction_map entries carry proper evidence.

Cap 2 calls. Advisor failures non-blocking.

## 8. DAG position

- **Phase:** 2
- **Depends on:** product (identity)
- **Runs in parallel with:** architecture, ownership

## 9. Failure handling

- No stack detected → use the pre-seeded standard policies only; add nothing.
- Web research fails on a proposed addition → drop the addition; standard policies cover most cases.
- User rejects the default halt action → record the choice and amend the contract; never soft-override.
