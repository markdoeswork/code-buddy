# code-buddy

A Neovim plugin. The mission: never leave Neovim to communicate and code with an LLM.

## Core philosophy

- **No modals, no floating windows** — all LLM interaction happens through code comments injected directly into the buffer
- **Write code, use the LLM as a tool** — user writes as much code as possible; the LLM handles conversion of pseudocode/wrong syntax and answers questions
- **Communication in comments** — user drops a marker comment (`--buddy`) in their file; the plugin reads it and responds by injecting comment blocks above that line
- **LSP-first context** — because the user runs lightweight LLMs, the plugin uses LSP (hover, references, diagnostics, documentSymbol) to build precise, minimal context rather than dumping whole files

## Architecture

```
lua/code-buddy/
  init.lua                    -- setup(), registers user commands
  language_helpers.lua        -- comment prefix per filetype
  capture/
    marker.lua                -- finds --buddy marker in buffer, parses flags (e.g. --code)
    function_name.lua         -- LSP documentSymbol → enclosing function for a row
    lsp.lua                   -- hover (signature) + references (ref count) + diagnostics
  commands/
    meta_data.lua             -- CodeBuddyMeta command handler
  commentor/
    injector.lua              -- injects/clears comment blocks; marks them with codebuddy-injected
  views/
    meta_data.lua             -- orchestrates: marker → fn symbol → LSP info → inject
    virtual_text/             -- virtual text rendering (eol, highlight, lines)
plugin/
  code-buddy.lua              -- calls setup()
```

## Commands

- `CodeBuddy` — placeholder (prints buffer name)
- `CodeBuddyMeta` — gather LSP metadata for enclosing function and inject as comments above cursor (or above `--buddy` marker if present)
- `CodeBuddyClear` — remove all injected comment blocks from the buffer

## Marker system

A line containing `--buddy` anywhere triggers marker mode. Additional flags can be appended:
- `--buddy --code` — also includes the full function source in the injected output

## Injected comment format

```
-- codebuddy: meta  [codebuddy-injected]
-- function: myFunc  [lines 10–25]
-- signature: func myFunc(x int) error
-- refs: 3 callers
-- ERROR: undefined variable foo
```

The `[codebuddy-injected]` tag is how `clear` finds and removes blocks.

## Key patterns

- All LSP calls are async with callbacks — don't block the UI
- Row numbers are 0-indexed throughout (nvim_buf_* API convention)
- `find_enclosing_symbol` picks the tightest (smallest line range) enclosing function/method (SymbolKind 6=Method, 12=Function)
- Comment prefix is per-language via `language_helpers.get_comment_prefix(bufnr)`
