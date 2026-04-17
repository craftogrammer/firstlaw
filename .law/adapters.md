# Tool adapter policy

> **Layer:** doctrine-adjacent · **Authority:** elaboration · **Mutability:** amendable
> Governs the relationship between repo law and tool-facing files (e.g. `CLAUDE.md`, `AGENTS.md`, `codex.md`, `.cursorrules`, `.cursor/rules/*`, `.github/copilot-instructions.md`, and any other file consumed by a coding agent or editor agent). Extensively checked and patched by the `adapter` subagent.

## Principle

Repo law lives in `CONSTITUTION.md` and `.law/contracts/*`. Tool-facing files are **adapters**: projections that translate or point at repo law in the shape a specific tool expects. They are **never authoritative**. On any conflict, the projection is defective.

## Discovery, not declaration

The kit does not ship a hardcoded list of adapter files. The `adapter` subagent discovers them each run via:

- **Heuristic filename patterns** — root-level `.md` files, hidden dirs and files matching `.<tool>*rules*` / `.<tool>rc*` / `.<tool>.conf*`, common tool subdirs (`.github/`, `.config/`, tool-specific hidden dirs).
- **Content heuristics** — first-person instructional voice addressed to an assistant/agent, rules lists, tool names, explicit system-prompt framing.
- **Live web research** — which tools currently use which filenames, retrieved with dates.

Single-signal matches are surfaced to the user for confirmation. Multi-signal matches are proposed for patching, also with user confirmation before any write.

## Non-destructive patching (hard rule)

The kit never overwrites user-owned adapter content. Patching rules:

1. **Delimited block.** All kit-managed content lives inside the delimiters below. Everything outside is user-owned and inviolate.

   ```
   <!-- BEGIN .law/CONSTITUTION-FIRST -->
   ...kit-managed content...
   <!-- END .law/CONSTITUTION-FIRST -->
   ```

2. **Update in place.** If the delimited block exists, the subagent updates content *inside* the delimiters only. Content before `BEGIN` and after `END` is preserved byte-for-byte.

3. **Prepend on absence.** If the block does not exist, the subagent prepends it. One exception: if the file has a YAML frontmatter (`---\n...\n---`) at the top, the block goes immediately *after* the frontmatter, never before.

4. **Halt on conflict.** If the existing content declares identity, domains, ownership, or dependency rules that contradict the contracts, the subagent does **not** patch. It halts on that file and surfaces the conflict for human resolution.

5. **Ask on ambiguity.** If the merge target is unclear — for example, the file has an existing block with a different delimiter, or the frontmatter shape is non-standard — the subagent halts on that file and asks.

6. **Record every patch.** Each successful patch is recorded in `project.contract.json#adapters.patched_files[]` with `path`, `patched_at`, and `discovery_method`. This is the audit trail.

## What adapters may contain

- A pointer to `CONSTITUTION.md` and the contracts as source of truth
- A summary of repo law in the format the tool expects
- Tool-specific operational instructions that do **not** contradict repo law (e.g. "run `pnpm test` before committing")
- Custom user content outside the delimited block

## What adapters must not contain

- Declarations of project identity, domain boundaries, truth ownership, dependency rules, or ambiguity policies in a form that could diverge from the contracts
- Anything that contradicts the constitution or any contract
- Rules that the user expects to be treated as law; those belong in the constitution or contracts

## Default constitution-first block template

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

The adapter subagent may extend this template for tool-specific preambles, but the delimiters and pointer list are mandatory.

## Conflict resolution

On any conflict between an adapter and repo law:

1. Repo law wins.
2. The adapter is defective and must be corrected — either by updating the delimited block or by amending the user-owned content outside it (with consent).
3. If the adapter expressed something the constitution failed to address, amend the constitution first, then update the adapter.

## Maintenance

- When contracts change, the orchestrator re-runs the `adapter` subagent to refresh the block contents (not the user-owned content).
- Adapters that no longer serve a living tool can be archived or deleted by the user. The kit does not auto-remove adapter files.
- No auto-generation of adapters the user hasn't already adopted.

## Discovery log

The `adapter` subagent appends newly observed patterns here across runs. Entries are evidence of what was found, not instructions.

<!-- ADAPTER_DISCOVERY_LOG_BEGIN -->
<!-- Each entry: date, file path, matched signals, tool identification (evidence or judgment), research URLs with retrieval dates -->
<!-- ADAPTER_DISCOVERY_LOG_END -->
