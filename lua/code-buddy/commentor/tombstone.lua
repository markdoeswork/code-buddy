-- After a --replace, injects a "done" comment recording what was asked and when.
-- Only injected if the --buddy marker line was removed by the replacement (normal case).
-- The comment uses --done so CodeBuddyMeta won't re-trigger on it.

local lang     = require("code-buddy.language_helpers")
local injector = require("code-buddy.commentor.injector")

local M = {}

-- Extract the human question from a raw --buddy line.
local function extract_question(marker_line)
  local q = marker_line:match("%-%-buddy%s+(.-)%s*%-%-") or
            marker_line:match("%-%-buddy%s+(.+)$") or ""
  return q:gsub("^%s+", ""):gsub("%s+$", "")
end

-- Returns true if any line in the buffer still contains --buddy.
local function buddy_still_present(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for _, l in ipairs(lines) do
    if l:find("--buddy", 1, true) then return true end
  end
  return false
end

-- Find the last line of the replaced function by scanning from sym.range.start
-- for the end of the new content (new_lines count tells us where it ends).
local function fn_end_row(sym, new_lines)
  return sym.range.start.line + #new_lines - 1
end

-- inject_tombstone inserts a --done comment at the end of the replaced function.
-- marker_line: the original raw --buddy line
-- sym:         LSP symbol (used to locate insertion point after replacement)
-- new_lines:   the lines written by replacer (to calculate new end row)
-- model:       model name string
function M.inject(bufnr, marker_line, sym, new_lines, model)
  if buddy_still_present(bufnr) then return end

  local question  = extract_question(marker_line)
  local timestamp = os.date("%Y-%m-%d %H:%M")
  local prefix    = lang.get_comment_prefix(bufnr)

  -- Insert one line above the closing line of the replaced function
  local insert_row = fn_end_row(sym, new_lines)

  local parts = { "--done" }
  if question ~= "" then parts[#parts + 1] = question end
  parts[#parts + 1] = timestamp
  parts[#parts + 1] = model

  local line = prefix .. table.concat(parts, "  |  ")
  vim.api.nvim_buf_set_lines(bufnr, insert_row, insert_row, false, { line })
end

return M
