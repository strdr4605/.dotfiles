#!/usr/bin/env node
// Reminder check for the pr-visual-recap skill. Input: one JSON argument {cwd, command, output}.
// Prints a reminder when `gh pr create` made a PR with no block, or when a push makes the block's
// **Head:** older than the pushed commit. Prints nothing otherwise. A push to a PR with no block
// prints nothing, so repos that do not use the skill get no noise.
import { START, repoSlug, run } from './upsert.mjs'

try {
  main(JSON.parse(process.argv[2]))
} catch {
  // A reminder must never break the session.
}


function main({ cwd, command, output }) {
  const repo = repoSlug(cwd)
  if (!repo) return

  const created = /gh\s+pr\s+create/.test(command)
  const notes = []
  for (const target of targets(cwd, command, output)) {
    const out = run('gh', ['pr', 'view', target.ref, '-R', repo, '--json', 'number,state,body,headRefOid'], cwd)
    if (!out) continue
    const pr = JSON.parse(out)
    if (pr.state !== 'OPEN') continue

    const head = target.sha || pr.headRefOid
    const stamp = pr.body.match(/\*\*Head:\*\*\s*`([0-9a-f]{7,40})`/)?.[1]
    if (!pr.body.includes(START)) {
      if (created) notes.push(`PR #${pr.number} has no pr-visual-recap block. Use the pr-visual-recap skill (create mode) to add it.`)
    } else if (!stamp || !head.startsWith(stamp)) {
      notes.push(`PR #${pr.number}: pr-visual-recap block is at \`${stamp ?? 'no sha'}\`, pushed head is \`${head.slice(0, 7)}\`. Use the pr-visual-recap skill (update mode).`)
    }
  }
  if (notes.length) console.log(notes.join('\n'))
}

// Each target is { ref: branch name or PR URL, sha: pushed commit or '' }.
function targets(cwd, command, output) {
  if (/gh\s+pr\s+create/.test(command)) {
    const url = output.match(/https:\/\/github\.com\/[^/\s"]+\/[^/\s"]+\/pull\/\d+/)?.[0]
    return url ? [{ ref: url, sha: '' }] : []
  }

  if (/jj\s+git\s+push/.test(command)) {
    const named = [...command.matchAll(/(?:-b|--bookmark)[=\s]+([^\s'"]+)/g)].map((m) => m[1])
    const revset = named.length ? named.map((b) => `bookmarks(exact:${JSON.stringify(b)})`).join(' | ') : 'heads(::@ & bookmarks())'
    const out = run('jj', ['log', '--no-graph', '-r', revset, '-T', 'local_bookmarks.map(|b| b.name() ++ " " ++ commit_id).join("\\n") ++ "\\n"'], cwd)
    return out.split('\n').filter(Boolean).map((l) => {
      const [ref, sha] = l.split(' ')
      return { ref, sha }
    })
  }

  const branch = run('git', ['branch', '--show-current'], cwd).trim()
  return branch ? [{ ref: branch, sha: run('git', ['rev-parse', 'HEAD'], cwd).trim() }] : []
}
