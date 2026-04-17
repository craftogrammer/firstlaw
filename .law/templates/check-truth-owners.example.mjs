#!/usr/bin/env node
// check-truth-owners.example — project-specific writer enforcement.
//
// This is an EXAMPLE. Copy into your project (typically scripts/) and
// adapt the `detectWriters` logic to your actual write paths (SQL, ORM,
// key-value store, API handlers — whatever owns mutation in your stack).
//
// Default behaviour: for each truth in truth-owners.contract.json whose
// storage looks like a SQL table, grep the working tree for INSERT/UPDATE/
// DELETE statements touching that table. If any file outside the declared
// `writer.module` writes the table, print the violation and exit 1.
//
// Trade-offs this example makes:
//   - regex SQL detection; misses query builders / ORMs / dynamic SQL
//   - no AST parse
//   - assumes writer.module is a file path or a folder prefix
// These are acceptable for a starter; swap in your real semantics when you
// adopt this.
//
// Run: node scripts/check-truth-owners.mjs

import { readFileSync, readdirSync, statSync } from "node:fs";
import { join, relative } from "node:path";

const CONTRACT = ".law/contracts/truth-owners.contract.json";
const ROOT = ".";
const EXCLUDES = new Set([".git", "node_modules", ".law", "vendor", "dist", "build", ".next"]);
const SQL_EXTS = new Set([".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs", ".sql", ".py", ".rb", ".go", ".rs", ".java", ".kt"]);

function walk(dir) {
  const out = [];
  for (const name of readdirSync(dir)) {
    if (EXCLUDES.has(name)) continue;
    const p = join(dir, name);
    const s = statSync(p);
    if (s.isDirectory()) out.push(...walk(p));
    else out.push(p);
  }
  return out;
}

function detectWriters(files, table) {
  const re = new RegExp(
    `\\b(INSERT\\s+INTO|UPDATE|DELETE\\s+FROM)\\s+["\`']?${table}["\`']?\\b`,
    "i",
  );
  const hits = [];
  for (const f of files) {
    const ext = f.slice(f.lastIndexOf("."));
    if (!SQL_EXTS.has(ext)) continue;
    const text = readFileSync(f, "utf8");
    if (re.test(text)) hits.push(relative(ROOT, f));
  }
  return hits;
}

const contract = JSON.parse(readFileSync(CONTRACT, "utf8"));
const truths = contract.truths || [];
const files = walk(ROOT);

let failed = 0;
for (const t of truths) {
  if (!t.subject || !t.writer || !t.writer.module) continue;
  if (t.storage && !/sql|sqlite|postgres|mysql|table/i.test(t.storage)) continue;
  const table = t.subject.replace(/\s+/g, "_");
  const writers = detectWriters(files, table);
  const declared = t.writer.module;
  const unauthorized = writers.filter((w) => !w.startsWith(declared));
  if (unauthorized.length) {
    console.error(`truth "${t.id || t.subject}" declared writer: ${declared}`);
    for (const w of unauthorized) console.error(`  unauthorized writer: ${w}`);
    failed++;
  }
}

process.exit(failed ? 1 : 0);
