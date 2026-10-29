#!/usr/bin/env node
// Writes the pr-visual-recap block into a PR body. Text outside the markers never changes.
// Usage: node upsert.mjs <pr-number|url> <block-file> [-R owner/repo] [--dry-run]
//        node upsert.mjs --self-test
import { execFileSync } from 'node:child_process'
import { readFileSync, realpathSync } from 'node:fs'
import { pathToFileURL } from 'node:url'
import assert from 'node:assert/strict'

export const START = '<!-- pr-visual-recap:start -->'
export const END = '<!-- pr-visual-recap:end -->'

// Run main only when executed directly, not when check.mjs imports it. realpath: ~/.pi is a symlink.
if (process.argv[1] && import.meta.url === pathToFileURL(realpathSync(process.argv[1])).href) main(process.argv.slice(2))


function main(args) {
  if (args[0] === '--self-test') {
    selfTest()
    console.log('self-test ok')
    return
  }

  const r = args.indexOf('-R')
  const repo = r === -1 ? repoSlug(process.cwd()) : args[r + 1]
  const [pr, blockFile] = args.filter((a, i) => !a.startsWith('-') && (r === -1 || i !== r + 1))
  if (!pr || !blockFile) die('usage: node upsert.mjs <pr-number|url> <block-file> [-R owner/repo] [--dry-run]')
  if (!repo) die('cannot find the GitHub repo from this directory: pass -R owner/repo')

  const block = readFileSync(blockFile, 'utf8').trim()
  const problem = checkBlock(block)
  if (problem) die(problem)

  const body = JSON.parse(execFileSync('gh', ['pr', 'view', pr, '-R', repo, '--json', 'body'], { encoding: 'utf8' })).body
  const next = upsert(body, block)

  if (args.includes('--dry-run')) {
    process.stdout.write(next)
    return
  }

  if (next === body) {
    console.log('PR body unchanged')
    return
  }

  execFileSync('gh', ['pr', 'edit', pr, '-R', repo, '--body-file', '-'], { input: next, stdio: ['pipe', 'inherit', 'inherit'] })
  console.log(`PR ${pr}: pr-visual-recap block written`)
}

// owner/repo of the origin remote. Works in git checkouts and in non-colocated jj repos.
export function repoSlug(cwd) {
  const url = run('git', ['remote', 'get-url', 'origin'], cwd) || (run('jj', ['git', 'remote', 'list'], cwd).match(/^origin\s+(\S+)/m)?.[1] ?? '')
  return url.trim().match(/github\.com[:/]([^/\s]+\/[^/\s]+?)(?:\.git)?$/)?.[1] ?? ''
}

export function run(cmd, args, cwd) {
  try {
    return execFileSync(cmd, args, { cwd, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'], timeout: 10000 })
  } catch {
    return ''
  }
}

function upsert(body, block) {
  const s = body.indexOf(START)
  const e = body.indexOf(END)
  if (s !== -1 && e > s) return body.slice(0, s) + block + body.slice(e + END.length)
  if (s !== -1 || e !== -1) die('broken marker pair in PR body: fix it by hand')

  // New block goes before the first section heading, so after any intro lines.
  const lines = body.split('\n')
  const i = lines.findIndex((l) => /^##\s/.test(l))
  if (i === -1) return body.trimEnd() + '\n\n' + block + '\n'
  lines.splice(i, 0, block, '')
  return lines.join('\n')
}

function checkBlock(block) {
  if (!block.startsWith(START) || !block.endsWith(END)) return `block must start with ${START} and end with ${END}`
  if (!/\*\*Head:\*\*\s*`[0-9a-f]{7,40}`/.test(block)) return 'block needs a **Head:** `<sha>` line'
  if ((block.match(/^\s*```/gm) || []).length % 2) return 'unbalanced code fences'

  for (const [, diagram] of block.matchAll(/```mermaid\n([\s\S]*?)```/g)) {
    if (!/^\s*sequenceDiagram/.test(diagram)) continue
    const bad = diagram.split('\n').find((l) => l.includes(';') && /(-{1,2}(>>|>|x|\))|^\s*Note\b)/.test(l))
    if (bad) return `";" in a sequence message breaks GitHub rendering: ${bad.trim()}`
  }
  return null
}

function die(message) {
  console.error(`upsert: ${message}`)
  process.exit(1)
}

function selfTest() {
  const ok = `${START}\n**Head:** \`abc1234\`\n${END}`
  const body = 'Intro\n\n> warning\n\n## Problem\ntext'

  assert.equal(upsert(body, ok), `Intro\n\n> warning\n\n${ok}\n\n## Problem\ntext`)
  assert.equal(upsert(upsert(body, ok), ok.replace('abc1234', 'def5678')), `Intro\n\n> warning\n\n${ok.replace('abc1234', 'def5678')}\n\n## Problem\ntext`)
  assert.equal(upsert('no headings', ok), `no headings\n\n${ok}\n`)

  assert.equal(checkBlock(ok), null)
  assert.match(checkBlock('no markers'), /must start/)
  assert.match(checkBlock(`${START}\n${END}`), /Head/)
  assert.match(checkBlock(`${START}\n**Head:** \`abc1234\`\n\`\`\`mermaid\nsequenceDiagram\n  A->>B: x; y\n\`\`\`\n${END}`), /";"/)
  assert.equal(checkBlock(`${START}\n**Head:** \`abc1234\`\n\`\`\`mermaid\nsequenceDiagram\n  A->>B: x, y\n\`\`\`\n${END}`), null)
}
