---
name: pr-visual-recap
description: Add or update the pr-visual-recap block in a GitHub pull request description. The block has a risk line, a touched-surfaces table, and 1-2 simple UML diagrams (Mermaid) that show how the system behaves after the PR, so reviewers understand the change without the code diff. Use after you create a PR, after you push review fixes to an open PR, when the pr-visual-recap reminder appears in a command result, or when the user asks for a visual recap or system diagram of a PR.
---

# PR visual recap

Goal: a reviewer understands what the system does differently after this PR, without reading the code diff. The block helps the review. It does not replace the diff review.

Every PR gets one block. A trivial PR gets the one-line form.

## Where the block goes

- In the PR body, between `<!-- pr-visual-recap:start -->` and `<!-- pr-visual-recap:end -->`.
- Not collapsed. The upsert script puts a new block before the first `## ` heading. If the body has no heading, the script adds the block at the end.
- The script never changes text outside the markers.

## Facts come from the diff

Get the PR data (add `-R <owner/repo>` when the directory is not a git checkout, for example a non-colocated jj repo):

```bash
gh pr view <n> --json number,baseRefName,headRefOid,files,body
gh pr diff <n>
```

- Every claim in the block must be true in this diff. Use the session context only to explain intent.
- If the diff does not show if a flow changed, read the file. Do not guess. An explicit "unknown" is better than a wrong diagram.
- `**Head:**` is the `headRefOid` you read, short form (7 characters).

## Create mode

1. Read the PR data and the diff.
2. List the touched surfaces. Kinds: page/screen, component, endpoint/route, handler/service, background job, external API, email/notification, table, cache key, config/env key, CLI command. Status: new, changed, or removed. Include only what a reviewer must know. Skip pure moves and formatting.
3. Set the risk (see Risk).
4. Draw 1-2 diagrams (see Diagrams). A trivial PR gets 0 diagrams and the one-line form.
5. Write the **Unchanged** line: what a reviewer could fear this PR touches, but it does not. It must be true in the diff.
6. Write the **Related paths** line: other places with the same logic (another client, endpoint, job, or report). Say "updated", "not updated: <why>", or "none". Remove the line when there are no such places.
7. Write the block to a temporary file. Copy the shape in [references/block-format.md](references/block-format.md).
8. Run the upsert script (see Commands). It is the only way to write the block. Do not put the block in `gh pr create --body` or `gh pr edit --body`: create the PR without it first. The script puts the block in the right place and checks it.

## Update mode

Use this after a push to a branch with an open PR, and after review fixes. A reminder appears in the push result when the block's `**Head:**` is not the pushed commit.

1. Make a new block from the full current PR diff (create mode, steps 1-7).
2. Compare it with the old block in the body.
3. If the system shape changed (a surface added, removed, or its status changed; a diagram changed; the risk changed):
   - Run the upsert script.
   - Add one comment. Reviewers get no notification for body edits.
     ```bash
     gh pr comment <n> --body 'Visual recap updated (`<old sha>` → `<new sha>`): <one line: what changed in the system>.'
     ```
4. If the shape did not change: change only `**Head:**`, run the upsert script, and add no comment.

## Risk

The highest match sets the level. The risk is advice only. Name the trigger in the heading, for example `risk: **high** (changes the login flow)`.

| Level | Triggers |
|---|---|
| high | money or payments; auth, permissions, sessions; schema, migrations, data deletion; public API contract; external API request or response; a job that writes data |
| medium | new or changed request flow; endpoint arguments or response shape; cache keys; background jobs that only read; emails/notifications |
| low | display, copy, styles, docs, tests only; no flow change |

## Diagrams

Pick the type:

| Type | Use for |
|---|---|
| `sequenceDiagram` (default) | A request flow: user → UI → API → service → DB / cache / external API |
| `flowchart` (activity) | Branching rules: validation, permissions, retries |
| `stateDiagram-v2` | Status transitions: order, job, account |
| `erDiagram` | Schema changes only: new table, column, or relation |

Do not use class diagrams. They show code, not the system.

Rules:

- Use a maximum of 2 diagrams. Add the second only if it shows something the first cannot.
- Every diagram must mark at least one change. Drop a diagram that marks no change. The upsert script rejects it.
- Show the system after the PR. Mark what changed:
  - Sequence: wrap new messages in `rect rgba(46, 160, 67, 0.15)`, changed in `rect rgba(210, 153, 34, 0.18)`, removed in `rect rgba(248, 81, 73, 0.15)` with a `-x` arrow and the word "removed".
  - Flowchart and state: `classDef new fill:#2ea04326,stroke:#2ea043`, `classDef changed fill:#d2992226,stroke:#d29922`, `classDef removed fill:#f8514926,stroke:#f85149,stroke-dasharray:4`. Then `class A,B new`.
  - ER: add `"NEW"`, `"CHANGED"`, or `"REMOVED"` as the attribute comment.
- Put a legend line under each diagram, with only the colors you used: `🟩 new · 🟨 changed · 🟥 removed`.
- Label = system name + file: `participant API as Orders API<br/>src/routes/orders.ts`. Use the names users and reviewers know.
- Keep it small: a maximum of 12 messages in a sequence and 15 nodes in a flowchart. Remove context that is not necessary to see the change.

## Mermaid safety

GitHub shows a red error box for a bad diagram. Obey these rules:

- Do not use `;` in sequence messages or notes. The upsert script rejects it.
- Put flowchart and state labels in quotes when they contain `( ) [ ] { } : < >`: `A["save()"]`.
- Use short alphanumeric IDs. Put the text in the label or after `as`.
- Do not use `end` as a node ID.
- Put a blank line before and after each code fence.
- Do not put secrets, personal data, or real customer values in diagrams. Use field names.

## Writing

Use short sentences, one fact in each sentence.

## Commands

```bash
node ~/.pi/agent/skills/pr-visual-recap/scripts/upsert.mjs <pr> <block-file> --dry-run   # print the new body
node ~/.pi/agent/skills/pr-visual-recap/scripts/upsert.mjs <pr> <block-file>             # write it
node ~/.pi/agent/skills/pr-visual-recap/scripts/upsert.mjs --self-test
```

- `<pr>` is a number or a PR URL.
- The script finds the repo from the current directory (`gh`, then `jj git remote list`). Use `-R <owner/repo>` to set it.
- Before it writes, the script checks the markers, the `**Head:**` line, the code fences, `;` in sequence messages, and that each diagram marks a change.

## Failure

- The upsert script exits non-zero: read the message, fix the block, run it again.
- "broken marker pair": the body has only one marker. Do not guess. Tell the user and ask them to fix the body by hand.
- The user reports a red Mermaid error on GitHub: fix the diagram with the safety rules, then run the upsert script again.
