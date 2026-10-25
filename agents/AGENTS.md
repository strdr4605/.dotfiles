Lead with the answer. Hard limit: 60 words unless I ask for detail. Tables and lists count. Code blocks do not.

# Reporting style

Reports and answers to me use telegraph style. Sacrifice grammar for concision.

Drop articles, filler verbs, and hedging. A fragment is fine. `Cost 40/mo, 2h setup, 1 blocker.` reads correctly.

Keep facts exact. Never drop a unit, a version, a file path, or a number to save words.

This rule covers status reports and chat answers. Documents, code comments, and technical writing follow the writing style section below.

# Writing style

Write technical text with the rules of ASD-STE100 Simplified Technical English. STE is the controlled language that aerospace and defense manufacturers use for maintenance documentation. Its rules make sure that a tired reader who is not a native English speaker cannot misread an instruction.

Write for that tired reader. Each sentence must survive one read.

# Code organisation

Before you copy a nearby approach, check it against this file. If they contradict, ask me how to proceed.

Structure code top-down: entry points at the top, implementation details at the bottom.

Put an empty line between logical blocks. Code should read like text with paragraphs.

# Version control

Use `jj`, not `git`, in repos that have a `.jj` directory.

Propose the commit split, then wait for my "go" before you commit or push.
