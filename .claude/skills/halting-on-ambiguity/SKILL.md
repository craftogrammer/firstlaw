---
name: halting-on-ambiguity
description: Use when two code paths do the same job under different names, the same setting is declared in two config surfaces, a field or table or responsibility has no declared owner, authoritative prose carries soft modal hedges with no enforcement path (the policy `rule-softness` in `ambiguity-policies.contract.json` enumerates the exact tokens), runtime behavior contradicts documented behavior, a test asserts one thing while production does another, a domain owner is unclear, a generic folder (`shared/`, `common/`, `utils/`, `lib/`, `core/`, `misc/`) is about to absorb new logic with no charter, or the agent catches itself about to pick between two equally plausible resolutions. Keywords: ambiguity, contradiction, duplicate, conflict, unclear ownership, soft rule, two writers, shadow write, drift, `contradiction_map`.
---

# Halting on ambiguity

## Overview
Ambiguity is a hard halt signal, never a hint. The agent records the ambiguity in `.law/context/current-system.json#contradiction_map` and applies the matching policy from `.law/contracts/ambiguity-policies.contract.json` — invention is forbidden. Anchor: CONSTITUTION §7.

## When to Use
Trigger the instant any of these surfaces:
- two code paths implementing one behavior under different names (matches policy `duplicate-logic`)
- a truth with more than one writer (matches policy `multiple-writers`)
- the same setting declared in two config surfaces (matches policy `config-in-two-places`)
- a field, table, or responsibility with no declared owner in `.law/contracts/truth-owners.contract.json` (matches policy `unclear-ownership`)
- authoritative prose (CONSTITUTION, contracts, doctrine, charters) carrying soft modal hedges with no enforcement path — the exact tokens are enumerated in policy `rule-softness` in `.law/contracts/ambiguity-policies.contract.json`
- runtime behavior contradicting documented behavior (matches policy `runtime-contradicts-docs`)
- a test asserting one thing while production does another — a runtime-vs-docs instance where the test is the declared contract
- a generic container (`shared/`, `common/`, `utils/`, `lib/`, `manager/`, `service/`, `helpers/`, `core/`, `misc/`) about to receive new logic with no charter entry in `.law/contracts/domain-map.contract.json` (CONSTITUTION §5 redirects this to §7)
- no policy in `.law/contracts/ambiguity-policies.contract.json#policies` matches the observed ambiguity — apply `rules.default_action_when_no_policy_matches`

Do not use when law is unambiguous and a single contract field or charter already dictates the answer; follow the law directly instead of opening an ambiguity entry.

## Rule
Ambiguity is a hard signal. Never resolve it silently. The resolution mechanism lives in `.law/contracts/ambiguity-policies.contract.json`. (CONSTITUTION §7.)

## Agent must
- halt the in-flight task the moment any trigger above fires
- record the observation in `.law/context/current-system.json#contradiction_map` before any further action
- locate the matching policy in `.law/contracts/ambiguity-policies.contract.json#policies` by `trigger` and execute its `action` and `action_detail` verbatim
- apply `rules.default_action_when_no_policy_matches` (`halt_and_escalate`) when no policy matches
- label the observation as `evidence` or `judgment` per CONSTITUTION §10 and `.law/doctrine/agent-behavior.md`
- surface the ambiguity to the user, citing the `id` of the matched policy and the CONSTITUTION §7 anchor
- co-locate any resulting contract amendment with the code change that motivated it (CONSTITUTION §9)
- for `rule-softness`, either add an enforcement path (contract entry, test, review gate) or delete the rule
- for `duplicate-logic` and `multiple-writers`, consolidate onto the owner declared in `.law/contracts/truth-owners.contract.json` and delete the loser
- for `runtime-contradicts-docs`, declare which side is correct and fix the other; refuse to leave both in place

## Agent must not
- invent a resolution
- resolve the ambiguity by preferring older code, newer code, the shorter diff, or the path most familiar from training data
- wrap the ambiguity in an abstraction, facade, re-export, event bus, or adapter to hide it (CONSTITUTION §6 applies — structural intent matters, not syntactic shape)
- route the contested logic into a generic container (`shared/`, `common/`, `utils/`, `lib/`, `manager/`, `service/`, `helpers/`, `core/`, `misc/`) to escape the ownership question (CONSTITUTION §5)
- soften a rule to match the current mess, or soften the mess to match the rule, without an explicit amendment (CONSTITUTION §10)
- proceed past the halt with a `TODO` comment, a `FIXME`, or a deferred ticket (CONSTITUTION §11)
- skip recording in `contradiction_map` on the grounds that the fix is trivial
- treat runtime truth as a precedence layer — it is evidence, not law (CONSTITUTION §1)
- present cosmetic resolutions as decisions when only one is coherent with law

## Rationalizations — STOP and re-read
| Excuse | Reality |
| --- | --- |
| "It is obvious which one is correct." | Obviousness is the bias of training data. The policy is binding regardless. Record and apply it. |
| "I will fix the contradiction after I finish this task." | CONSTITUTION §11 forbids deferral. The task is blocked until the ambiguity is recorded and resolved. |
| "Both paths work, so nothing is broken." | Two working paths that will disagree later is exactly the failure CONSTITUTION §7 exists to prevent. |
| "This is just a duplicate helper, not an ambiguity." | Policy `duplicate-logic` exists for exactly this. Halt and consolidate to the declared owner. |
| "The rule is phrased as a soft modal hedge, so it is advisory." | Policy `rule-softness` classifies that phrasing as ambiguity. Harden the rule or delete it. |
| "The test is outdated — production is correct." | Policy `runtime-contradicts-docs` requires an explicit declaration of which side wins and a fix, not an assumption. |
| "No policy matches, so I will apply my own judgment." | The default action is `halt_and_escalate`. Judgment is not a resolution. |
| "Recording a contradiction will slow the task down." | Silent resolution is the violation. Recording is the minimum viable halt. |
| "I will put it in `shared/` for now." | CONSTITUTION §5 prohibits generic containers as ambiguity escape hatches. |
| "The user asked me to just pick one." | The user's request does not amend contracts. Surface the ambiguity; do not absorb the pressure. |

## Red flags
If any of these thoughts surfaces, the rule is about to be violated — halt, re-read CONSTITUTION §7, open `contradiction_map`.
- "Let me wrap both in a single interface."
- "I will delete the older one — it looks abandoned."
- "This is fine; the two configs agree right now."
- "I will add a comment explaining the discrepancy."
- "I will introduce a shim so neither side has to change."
- "The contract does not list this case, so I am free to decide."
- "No one writes to this field anymore." (check `truth-owners.contract.json`; absence from the contract is the ambiguity)
- "`utils/` is fine as a home."
- "I will record it later once I know the answer."
- "The test is wrong."
- "The docs are wrong."
- "Both are wrong — I will replace them with a third."

## Machine-readable contract
`.law/contracts/ambiguity-policies.contract.json`
