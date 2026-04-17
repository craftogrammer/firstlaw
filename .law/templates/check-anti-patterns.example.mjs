#!/usr/bin/env node
// check-anti-patterns.example — simple project-wide gates.
//
// This is an EXAMPLE. Copy into your project (typically scripts/) and
// tune the thresholds / patterns to match your doctrine. This starter
// ships three cheap but real checks:
//
//   1. File-size cap (default 300 lines) with an allowlist for files
//      you haven't decomposed yet. Matches the pattern seen in mature
//      codebases (ratcheting allowlist).
//   2. Forbidden regex patterns (e.g. layered `??` fallback chains,
//      `as any` type escapes) scoped by path prefix.
//   3. Generic-folder names (shared/, common/, utils/, lib/) that lack
//      a charter in .law/charters/.
//
// Run: node scripts/check-anti-patterns.mjs

import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { join, relative } from "node:path";

const EXCLUDES = new Set([".git", "node_modules", ".law", "dist", "build", ".next", "vendor"]);
const CODE_EXTS = new Set([".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs", ".py", ".go", ".rs"]);

// -------- tune these --------
const MAX_LINES = 300;
const ALLOWLIST = new Set([
  // "src/legacy/bigFile.ts",
]);
const FORBIDDEN_PATTERNS = [
  { pattern: /\bas\s+any\b/, scope: "src/", label: "as-any type escape" },
  { pattern: /\?\?.*\?\?/, scope: "src/features/", label: "layered ?? fallback chain" },
];
const GENERIC_FOLDERS = ["shared", "common", "utils", "lib", "helpers", "core", "misc"];
const CHARTERS_DIR = ".law/charters";
const SRC_ROOTS = ["src", "app"];
// ----------------------------

function walk(dir, out = []) {
  let entries;
  try { entries = readdirSync(dir); } catch { return out; }
  for (const name of entries) {
    if (EXCLUDES.has(name)) continue;
    const p = join(dir, name);
    const s = statSync(p);
    if (s.isDirectory()) walk(p, out);
    else out.push(p);
  }
  return out;
}

let failed = 0;

// 1. file-size cap
for (const root of SRC_ROOTS) {
  for (const f of walk(root)) {
    const ext = f.slice(f.lastIndexOf("."));
    if (!CODE_EXTS.has(ext)) continue;
    const rel = relative(".", f);
    if (ALLOWLIST.has(rel)) continue;
    const lines = readFileSync(f, "utf8").split("\n").length;
    if (lines > MAX_LINES) {
      console.error(`file-size: ${rel} = ${lines} lines (cap ${MAX_LINES})`);
      failed++;
    }
  }
}

// 2. forbidden patterns
for (const { pattern, scope, label } of FORBIDDEN_PATTERNS) {
  for (const f of walk(scope)) {
    const ext = f.slice(f.lastIndexOf("."));
    if (!CODE_EXTS.has(ext)) continue;
    const text = readFileSync(f, "utf8");
    const match = text.match(pattern);
    if (match) {
      console.error(`${label}: ${relative(".", f)} — matched "${match[0]}"`);
      failed++;
    }
  }
}

// 3. generic folders without a charter
for (const root of SRC_ROOTS) {
  let entries;
  try { entries = readdirSync(root); } catch { continue; }
  for (const name of entries) {
    if (!GENERIC_FOLDERS.includes(name)) continue;
    const charter = join(CHARTERS_DIR, `${name}.md`);
    if (!existsSync(charter)) {
      console.error(`generic folder ${root}/${name}/ has no charter at ${charter}`);
      failed++;
    }
  }
}

process.exit(failed ? 1 : 0);
