#!/usr/bin/env node
// check-dep-direction.example — cross-domain import enforcement.
//
// EXAMPLE. Copy into your project (typically scripts/) and replace the
// `classifyLayer` function with your real layer classifier. The
// contract-reading and violation-reporting scaffold stays the same.
//
// Default behaviour: classifies each source file by its top-level folder
// name (e.g. src/shell/, src/domain/, src/shared/) matching declared
// domains in dependency-rules.contract.json. Extracts `import/from`
// statements and checks each edge against the allowed/forbidden lists.
//
// Limitations this example accepts:
//   - top-level folder only; skips path aliases (@/shell/...)
//   - regex import extraction; misses dynamic imports, re-exports
//   - TS/JS only
// Swap in per-project semantics (path alias resolver, AST parser,
// multi-language extractor) on adoption.
//
// Run: node scripts/check-dep-direction.mjs

import { readFileSync, readdirSync, statSync } from "node:fs";
import { join, relative } from "node:path";

const CONTRACT = ".law/contracts/dependency-rules.contract.json";
const SRC_ROOTS = ["src", "app", "lib"];
const EXCLUDES = new Set([".git", "node_modules", ".law", "dist", "build", ".next", "vendor"]);
const EXTS = new Set([".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs"]);

function walk(dir, out = []) {
  let entries;
  try { entries = readdirSync(dir); } catch { return out; }
  for (const name of entries) {
    if (EXCLUDES.has(name)) continue;
    const p = join(dir, name);
    const s = statSync(p);
    if (s.isDirectory()) walk(p, out);
    else if (EXTS.has(p.slice(p.lastIndexOf(".")))) out.push(p);
  }
  return out;
}

function classifyLayer(filePath, domains) {
  // replace with your project's real classifier (path aliases, package
  // names, monorepo layout, etc.)
  for (const root of SRC_ROOTS) {
    const prefix = `${root}/`;
    if (filePath.startsWith(prefix)) {
      const seg = filePath.slice(prefix.length).split("/")[0];
      if (domains.includes(seg)) return seg;
    }
  }
  return null;
}

function extractImports(text) {
  // matches `import ... from "x"`, `from "x"`, `require("x")`
  const re = /(?:from\s+|require\s*\(\s*)["']([^"']+)["']/g;
  const out = [];
  let m;
  while ((m = re.exec(text))) out.push(m[1]);
  return out;
}

function resolveImportLayer(from, imp, domains) {
  if (imp.startsWith(".")) {
    // relative; resolve against from
    const parts = from.split("/").slice(0, -1);
    for (const seg of imp.split("/")) {
      if (seg === "..") parts.pop();
      else if (seg !== ".") parts.push(seg);
    }
    return classifyLayer(parts.join("/"), domains);
  }
  return null; // external or unresolved alias
}

const contract = JSON.parse(readFileSync(CONTRACT, "utf8"));
const domains = contract.domains || [];
const allowed = new Set((contract.allowed || []).map((e) => `${e.from}->${e.to}`));
const forbidden = new Set((contract.forbidden || []).map((e) => `${e.from}->${e.to}`));

const files = SRC_ROOTS.flatMap((r) => walk(r));
let failed = 0;
for (const f of files) {
  const rel = relative(".", f);
  const src = classifyLayer(rel, domains);
  if (!src) continue;
  const text = readFileSync(f, "utf8");
  for (const imp of extractImports(text)) {
    const dst = resolveImportLayer(rel, imp, domains);
    if (!dst || dst === src) continue;
    const edge = `${src}->${dst}`;
    if (forbidden.has(edge)) {
      console.error(`forbidden edge ${edge}: ${rel} imports ${imp}`);
      failed++;
    } else if (!allowed.has(edge)) {
      console.error(`undeclared edge ${edge}: ${rel} imports ${imp}`);
      failed++;
    }
  }
}

process.exit(failed ? 1 : 0);
