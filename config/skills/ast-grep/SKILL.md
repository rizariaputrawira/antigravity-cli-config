---
name: ast-grep
description: >-
  Structural code search and replace using ast-grep (sg), a tree-sitter based tool for
  pattern matching on code structure rather than text. Use when searching for code patterns
  structurally (e.g., all function calls with a specific argument shape, all class definitions,
  all try-catch blocks), performing structural refactoring across many files, or when grep
  would be too imprecise because the pattern spans multiple lines or has variable whitespace.
  Triggers: 'ast-grep', 'structural search', 'code pattern search', 'find all calls to',
  'structural refactor', 'tree-sitter search'.
---

# AST-Grep Skill

Uses `ast-grep` (`sg`) for structural code search and replace using tree-sitter AST patterns.

## Installation Check

First verify ast-grep is available:
```bash
sg --version 2>/dev/null || echo "NOT INSTALLED"
```

If not installed:
```bash
# macOS
brew install ast-grep
# Linux/npm
npm install -g @ast-grep/cli
# Cargo
cargo install ast-grep --locked
```

## Core Commands

### Search
```bash
# Find pattern in a language
sg -p '<pattern>' -l <lang> <path>

# Examples:
sg -p 'console.log($$$ARGS)' -l ts src/       # all console.log calls
sg -p 'async function $NAME($$$) { $$$ }' -l ts .  # all async functions
sg -p 'try { $$$ } catch($E) {}' -l ts .      # empty catch blocks
sg -p 'import { $$$IMPORTS } from "$MODULE"' -l ts . # all named imports
```

### Replace (structural)
```bash
# Replace pattern with rewrite
sg -p '<pattern>' --rewrite '<replacement>' -l <lang> <path>

# Dry run first (no changes):
sg -p '<pattern>' --rewrite '<replacement>' -l <lang> <path> --dry-run

# Apply interactively:
sg -p '<pattern>' --rewrite '<replacement>' -l <lang> <path> -i

# Apply without confirmation:
sg -p '<pattern>' --rewrite '<replacement>' -l <lang> <path> --update-all
```

### Count matches
```bash
sg -p '<pattern>' -l <lang> <path> --count
```

## Pattern Syntax

| Metavariable | Matches | Example |
|---|---|---|
| `$NAME` | Single node | `$FUNC($ARGS)` |
| `$$$ARGS` | Zero or more nodes | `foo($$$ARGS)` |
| `$$BODY` | One or more nodes | `if ($C) { $$BODY }` |
| `$_` | Any single node (unnamed) | `return $_` |

## Language Flags

| Flag | Language |
|---|---|
| `-l ts` | TypeScript |
| `-l tsx` | TypeScript React |
| `-l js` | JavaScript |
| `-l py` | Python |
| `-l rs` | Rust |
| `-l go` | Go |
| `-l java` | Java |

## Common Patterns

```bash
# Find all TODO comments
sg -p '// TODO: $$$' -l ts .

# Find all await calls
sg -p 'await $EXPR' -l ts .

# Find classes that extend something
sg -p 'class $NAME extends $BASE { $$$ }' -l ts .

# Find all throw statements
sg -p 'throw new $ERROR($MSG)' -l ts .

# Find React hooks
sg -p 'const [$STATE, $SETTER] = useState($INIT)' -l tsx .

# Find Python function definitions
sg -p 'def $NAME($$$PARAMS): $$$' -l py .
```

## Workflow: Search → Verify → Replace

1. **Search** to find and count matches: `sg -p '<pattern>' -l <lang> . --count`
2. **Inspect** a sample: `sg -p '<pattern>' -l <lang> . | head -50`
3. **Dry-run** the replacement: `sg -p '<pattern>' --rewrite '<rewrite>' -l <lang> . --dry-run`
4. **Review** the diff carefully
5. **Apply** if correct: `sg -p '<pattern>' --rewrite '<rewrite>' -l <lang> . --update-all`
6. **Verify** by running tests
