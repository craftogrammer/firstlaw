---
name: checking-truth-ownership-before-mutating
description: Use when about to write a database field, run SQL `INSERT`/`UPDATE`/`DELETE`, call an ORM `save`/`create`/`update`, mutate a schema column, edit a config file, flip a feature flag, rotate a secret, set an environment variable, write a cache entry, update JSON schema, or persist any value another module reads back. Fires on adding a "small helper" under `shared/`, `utils/`, `lib/`, `common/`, or `core/` that writes state; on adding a second writer "just this once"; on rotating or backfilling data; on introducing a migration; on writing through middleware or a generic service wrapper.
---

# Checking truth ownership before mutating

## Overview
Every piece of runtime truth has exactly one writing domain. Consult `.law/contracts/truth-owners.contract.json` before any mutation, refuse to become a second writer, and register newly introduced truth in the same change. CONSTITUTION §5.

## When to Use
Triggering symptoms:
- diff contains SQL `INSERT`, `UPDATE`, `DELETE`, `UPSERT`, `MERGE`, `ALTER TABLE`, or `CREATE TABLE`
- diff calls `.save()`, `.create()`, `.update()`, `.delete()`, `.put()`, `.set()`, `.write()` on an ORM, KV, cache, or blob store
- diff edits a `.env`, `.yaml`, `.toml`, `.ini`, `.json` config file or a feature-flag registry
- diff rotates a secret, mints a token, or reassigns a credential
- diff writes into `localStorage`, `sessionStorage`, Redis, Memcached, or any cross-process cache
- diff introduces a migration, seed, backfill, or one-off script that mutates persisted state
- diff adds a writer inside `shared/`, `utils/`, `lib/`, `common/`, `helpers/`, `manager/`, `service/`, `core/`, `misc/`
- diff wraps an existing owner's write behind middleware, a decorator, an event bus, or a facade
- diff adds a new column, field, key, or JSON property read back by another module

Not for use: pure reads, in-memory computation with no persistence, local test fixtures scoped to one test, code under review that touches no runtime truth.

## Rule
No mutation lands until `truth-owners.contract.json` names a single owning domain for the target truth and the mutating code lives inside that domain.

## Agent must
- halt before the write and open `.law/contracts/truth-owners.contract.json`
- locate the target field, table, key, config path, or flag by exact name in `truths[]`
- refuse the mutation when the declared `writer` is not the current domain; route the call through the declared writer instead
- register the truth in `truth-owners.contract.json#truths` in the same commit when no entry exists, naming exactly one `writer`, listing readers, and stamping `last_validated_at`
- cross-check the owning domain against `.law/contracts/domain-map.contract.json#domains`; refuse if the domain is absent or is a generic container (`shared`, `common`, `utils`, `lib`, `helpers`, `manager`, `service`, `core`, `misc`) without an explicit entry and charter
- surface shadow-write attempts — helpers, middleware, facades, event buses, re-exports that write owned truth from outside the owner — and record them in `.law/context/current-system.json#contradiction_map`
- apply `.law/contracts/ambiguity-policies.contract.json#multiple-writers` on discovering a second existing writer; escalate, do not extend
- amend `truth-owners.contract.json` with a dated note when ownership legitimately transfers; never edit ownership silently

## Agent must not
- write the field first and register the truth "after the diff lands"
- add a writer inside a generic container on the grounds that "it's only one line" or "no real home exists yet"
- wrap the mutation in a utility, middleware, decorator, or event emitter to dodge the single-writer rule
- declare a second writer "temporary", "fallback", "migration-only", or "behind a flag"
- resolve an ownership gap by picking the closest-looking existing domain — halt and propose an amendment
- treat a migration, backfill, or admin script as exempt from ownership
- soften the rule by calling the second write a "sync", "shadow copy", "mirror", or "projection"

## Rationalizations — STOP and re-read
| Excuse | Reality |
| --- | --- |
| "It's a one-line patch — registering truth is overkill." | One unregistered write is how multi-writer truth begins. Register it or do not write it. |
| "I'll drop a helper in `utils/` so both callers share it." | Generic containers are forbidden owners (CONSTITUTION §5). The shared helper is the shadow writer. |
| "The second writer is temporary, until we refactor." | `shadow_writes_forbidden: true` has no temporary clause. Refactor first, then write. |
| "The real owner is unclear, so I'll just pick the closer module." | Unclear ownership is an ambiguity class (Article 7). Halt and record, do not guess. |
| "Migrations are infra, not domain writes." | A migration mutating persisted state is a write. It routes through the owner or it does not run. |
| "Middleware isn't really a writer — it just forwards." | Forwarding a mutation from outside the owning domain is a shadow write. Structural intent, not syntactic shape (CONSTITUTION §6). |
| "Feature flags live in config, not the domain model." | Flags read back by other modules are runtime truth. They need a writer entry. |
| "I'll backfill the contract at the end of the PR." | Article 9 requires co-located updates. "Later" does not arrive. |
| "This field is so obvious it doesn't need registering." | Obvious to the author, invisible to the next writer. Register it. |
| "The existing writer is broken, so I'll patch around it." | Patching around an owner creates a second writer. Fix the owner or amend ownership. |

## Red flags
- the word `shared`, `common`, `utils`, `lib`, `helpers`, `manager`, `service`, `core`, or `misc` appears in the path of a file that writes state
- the diff adds a write but does not touch `.law/contracts/truth-owners.contract.json`
- the truth is "about to be registered" in a follow-up PR
- two modules in the diff call `.save()` or equivalent on the same entity
- a write happens inside a decorator, middleware, interceptor, event handler, or job runner that is not the declared owner
- a migration, seed, or ops script mutates state no contract entry covers
- the phrase "for now", "temporarily", "until refactor", "as a stopgap", "behind a flag", or "shadow copy" appears near a write
- a config file gains a new key with no corresponding `truths[]` entry
- a secret rotation writes the new secret from a module other than the declared secret owner
- the owning domain in `domain-map.contract.json` lacks a charter file under `.law/charters/`

## Machine-readable contract
`.law/contracts/truth-owners.contract.json` (cross-reference `.law/contracts/domain-map.contract.json`, `.law/contracts/ambiguity-policies.contract.json`).
