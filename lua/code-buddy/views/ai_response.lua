-- Orchestrates the --ai flow:
--   1. Build prompt from marker question + collected meta lines
--   2. Start loading spinner
--   3. Call the API
--   4. Stop spinner, inject AI reply as comments

local api = require("code-buddy.ai_api.api")
local prompt    = require("code-buddy.ai_api.prompt")
local loading   = require("code-buddy.views.virtual_text.loading")
local injector  = require("code-buddy.commentor.injector")
local extractor = require("code-buddy.code-parser.extractor")
local replacer  = require("code-buddy.commentor.replacer")
local tombstone = require("code-buddy.commentor.tombstone")

local M = {}

-- marker_line: raw text of the --buddy line (for extracting the question)
-- meta_lines:  already-assembled context lines (from meta_data.show)
-- bufnr, row:  where to inject the response
function M.run(bufnr, row, marker_line, meta_lines)
  local prompt_text = prompt.build(marker_line, meta_lines)

  loading.start(bufnr, row)

  api.chat(prompt_text, function(ok, text)
    loading.stop(bufnr)

    local reply_lines
    if ok then
      reply_lines = vim.split(text, "\n", { plain = true })
    else
      reply_lines = { "ai error: " .. text }
    end

    injector.inject(bufnr, row, reply_lines, { label = "ai" })
  end)
end

-- Replace flow: LLM returns the full updated function; write it back to the buffer.
-- sym:      LSP DocumentSymbol with the original function's line range
-- fn_lines: raw source lines of the function (for the prompt)
function M.run_replace(bufnr, row, marker_line, sym, fn_lines)
  local prompt_text = prompt.build_replace(marker_line, fn_lines)

  local start_time = os.date("%H:%M:%S")
  loading.start(bufnr, row)

  api.chat(prompt_text, function(ok, text)
    loading.stop(bufnr)

    if not ok then
      injector.inject(bufnr, row, { "ai error: " .. text }, { label = "ai" })
      return
    end

    local new_lines = extractor.extract(text)
    if #new_lines == 0 then
      injector.inject(bufnr, row, { "replace failed: empty response" }, { label = "ai" })
      return
    end

    -- Clear injected blocks first so sym.range line numbers match the original buffer
    injector.clear(bufnr)
    replacer.replace(bufnr, sym, new_lines)
    tombstone.inject(bufnr, marker_line, sym, new_lines, api.MODEL, start_time)

    -- Re-indent the whole replaced range (function + tombstone) using buffer indent rules
    local s = sym.range.start.line + 1  -- 1-indexed
    local e = sym.range.start.line + #new_lines + 2  -- +2 for the two tombstone lines
    vim.cmd(s .. "," .. e .. "normal! ==")
  end)
end

return M
