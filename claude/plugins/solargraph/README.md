# Solargraph Plugin for Claude Code

Claude Code LSP plugin that integrates [Solargraph](https://solargraph.org/) for Ruby language intelligence.

## Features

- **Hover** — type info and documentation on methods/classes
- **Diagnostics** — type checking and RuboCop violations
- **Completion** — code completion for Ruby

## Supported file types

`.rb`, `.rake`, `.gemspec`

## Prerequisites

```sh
gem install solargraph
```

## Installation

Add to your Claude Code settings (`claude.json`):

```json
{
  "plugins": ["path/to/claude/plugins/solargraph"]
}
```

## Configuration

LSP settings are defined in `.lsp.json`. Defaults:

```json
{
  "solargraph": {
    "diagnostics": true,
    "completion": true,
    "hover": true
  }
}
```
