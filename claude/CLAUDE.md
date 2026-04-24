# Language Policy

User-facing output (plans, answers, option lists) should be in Japanese.
Internal processing (understanding requirements, research, reasoning, analysis) should be in English.

---

# Research Delegation Policy

## When to use tech-researcher agent

ALWAYS delegate to `tech-researcher` when technical research is needed:

- Latest versions, recent changes, or current best practices
- API specifications, library documentation, or error solutions
- Any topic where up-to-date accuracy matters

## When NOT to delegate

- User explicitly says "don't search" or "from your knowledge"
- Pure code implementation (research first, then implement separately)

---

# Plan Visualization

When a Plan includes architecture or process flows, visualize them with Mermaid diagrams.

---

# Bash Command Style

Follow these rules in order of priority to minimize permission prompts.

## 1. Prefer script delegation

If a flow will issue 3+ bash commands for a shared purpose, move them into `*/scripts/*.sh` first. `Bash(bash */.claude/skills/*/scripts/*.sh *)` is pre-approved, so approval is requested only once. It also sidesteps shell-variable and working-directory persistence issues across invocations.

## 2. Do not chain commands

Do not join commands with `&&`, `||`, or `;`. Run each as an independent Bash invocation. Permission matching runs against the full command string, so chaining breaks individual allow patterns. Exception: command substitutions like `tmpdir=$(mktemp -d)` count as a single logical operation.

When `cd` is needed, issue `cd /path` on its own and let subsequent commands inherit the working directory — do not write `cd /path && cmd`. If a one-shot invocation is truly required, use working-directory arguments like `git -C <path> ...` instead.

## 3. Trust exit codes

Do not insert diagnostic, verification, or progress bash commands. Commands report failures via exit code; downstream scripts handle their own preconditions.
