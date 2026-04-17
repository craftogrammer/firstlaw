# Subagent contract: adapter

## 1. Identity

- **id:** `adapter`
- **goal:** Discover tool-facing agentic files in the repo via heuristics + live web research, confirm patch targets with the user, and inject a clearly delimited constitution-first block **non-destructively**. Never overwrite user-owned content.

## 2. Reads

- `project.contract.json` (project name, mode)
- `.law/adapters.md` (policy; required reading before any patch)
- `.law/contracts/doc-taxonomy.contract.json` — layer `adapter`'s `location_pattern` as a starting glob (guidance, not a hardcoded list)
- Repo root and one level deep — full directory listing
- Content heads (first 200 lines) of any suspicious file identified by heuristics

## 3. Researches (hard rule: live web, retrieval dates required)

Agentic tool files evolve fast. Research current known agentic file conventions, including but not confined to:

- Files consumed by CLI coding agents, editor agents, model-routing layers, and IDE extensions
- Naming conventions (`*.md` at root with agent-directed content; `.<tool>rules`; `.<tool>/rules/*`; `.<tool>rc`; `.<tool>.conf*`)
- Filesystem locations (repo root, `.github/`, `.config/`, tool-specific hidden dirs)

Deliver: a ranked list of candidate files found in this repo + their probable tool, with retrieval-dated citations for any non-obvious classification.

**Do not rely on a hardcoded list.** The pre-seeded glob in the `doc-taxonomy` contract is a starting point, not authoritative.

## 4. Heuristics for discovery

Combine these signals; single signals are weak, combinations are strong:

- **Filename patterns**: root-level `.md` files with agent-directed names; hidden files/dirs matching `.<tool>*rules*`, `.<tool>rc*`, `.<tool>.conf*`
- **Content signals**: first-person instructional voice addressed to an "assistant", "agent", "you are", rules lists, tool names, explicit "system prompt" framing
- **Path signals**: files under `.github/`, `.<tool>/`, `docs/agents/`, `prompts/`
- **Frontmatter signals**: YAML frontmatter with tool-specific keys

Any file flagged by ≥2 signals is a candidate. Single-signal candidates are surfaced for user confirmation only.

## 5. Elicits

- **Confirm patch targets** — present the candidate list to the user, confirm which to patch. (blocking for any candidate the subagent proposes to patch)
- **Approve or edit the header text** — the constitution-first block is shown, user approves or edits (non-blocking; default template from `.law/adapters.md`)
- **Unknown patterns** — if a file matches heuristics but no known tool, ask the user what tool it serves (non-blocking; record the user's answer for future runs)
- **Offer pre-commit hook install** — if the repo has `.git/` and `.git/hooks/pre-commit` does not already invoke `.law/bin/*` scripts, offer to install `.law/git-hooks/pre-commit.sample` at `.git/hooks/pre-commit`. (non-blocking) If the user accepts, install; if the user declines, record the decline as a non-blocking entry in `.law/context/pending-questions.json` so future sessions do not re-ask.

## 6. Produces (non-destructive patching spec)

For each confirmed patch target:

1. Read the existing file content in full.
2. Check for an existing constitution-first block delimited by:
   ```
   <!-- BEGIN .law/CONSTITUTION-FIRST -->
   ...
   <!-- END .law/CONSTITUTION-FIRST -->
   ```
3. If present: **update the block contents only**, preserving everything before `BEGIN` and after `END` verbatim.
4. If absent: **prepend** a new block at the top of the file. Do not modify any other content.
5. If the file contains a YAML frontmatter block (`---\n...\n---`) at the top, insert the constitution-first block **immediately after** the frontmatter, not before it.
6. If the existing content appears to directly conflict with repo law (e.g. declares identity, domains, or ownership that contradicts contracts), **halt and ask** the user before patching — do not force a conflicting projection.

Patches also:

- `project.contract.json#adapters.patched_files[]` — record each patch with timestamp and discovery method
- `.law/adapters.md` — append to discovery log section if new patterns were identified

Pre-commit hook installation (if accepted in §5):

1. Confirm `.git/hooks/pre-commit` does not exist, or exists and does not already invoke `.law/bin/*` scripts. Never overwrite an existing hook blindly — if one is present, show its content to the user and ask whether to replace, chain, or skip.
2. Copy `.law/git-hooks/pre-commit.sample` to `.git/hooks/pre-commit` and make it executable.
3. Run the new hook once against the current working tree. If it fails, do not leave a failing hook in place — revert the install and surface the failure to the user.
4. Record the install in the envelope.

If the repo uses `core.hooksPath` pointing elsewhere (e.g. a lefthook or husky setup), do not fight that system. Note the detection, offer to either install into the configured hooks path or skip, and record the user's choice.

## 7. Constitution-first block content (template)

```
<!-- BEGIN .law/CONSTITUTION-FIRST -->
# Repo law is authoritative. This file is a projection.

Source of truth for this project is `CONSTITUTION.md` and the contracts in `.law/contracts/`.
Read those first. This file contains only tool-specific guidance and may not contradict them.

Before acting, read:
- `CONSTITUTION.md` — top-level repo law
- `.law/KIT_INDEX.md` — map of `.law/`
- `.law/contracts/project.contract.json` — identity, mode, pointers
- `.law/doctrine/agent-behavior.md` — how agents must behave in this repo

Do not infer project identity, domain boundaries, or ownership rules from this file.
Consult the contracts. On conflict, the constitution wins and this file is defective.
<!-- END .law/CONSTITUTION-FIRST -->
```

The block is self-contained. Anything the user keeps outside the delimiters is never touched.

## 8. Envelope

- `subagent_id`: `"adapter"`
- `decisions[]`: patch decisions (target file, action: prepend/update/skip/halt)
- `evidence[]`: file paths, content excerpts showing heuristic matches, web sources for tool identification with retrieved_at
- `judgment[]`: tool identification when not directly confirmable
- `questions_for_orchestrator[]`: uncertain candidates requiring user decision
- `proposed_contract_patches[]`: patches to `project.contract.json#adapters.patched_files` and `.law/adapters.md`

## 9. Advisor checkpoints

- **Checkpoint A — before any patch**: consult advisor with the full candidate list and proposed actions. Looking for: files that should not be patched, user content that might be damaged.
- **Checkpoint B — before finalizing envelope**: validate that no patch overwrote user content.

Cap 2 calls. Advisor failures non-blocking.

## 10. DAG position

- **Phase:** 3
- **Depends on:** product, architecture, ownership, ambiguity, doc-taxonomy (reads all filled contracts — the constitution-first header references them)
- **Runs in parallel with:** quality-audit

## 11. Failure handling

- Unable to parse a file's existing structure safely → skip the file, record in envelope with confidence note.
- User unavailable on patch-target confirmation → accumulate candidates in `.law/context/pending-questions.json`; do not patch anything without confirmation.
- Conflict detected between existing content and repo law → halt on that file, record the conflict, recommend manual reconciliation.
- Web research fails → proceed with strong-signal candidates only; weak-signal candidates deferred to `pending-questions.json`.
