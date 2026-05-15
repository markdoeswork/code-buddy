-- Replaces a function's source lines in the buffer with new_lines.
-- Uses the LSP DocumentSymbol range which is 0-indexed and inclusive on both ends.

local M = {}

-- sym:       LSP DocumentSymbol with sym.range.start.line and sym.range["end"].line
-- new_lines: table of strings to write in place of the original function
function M.replace(bufnr, sym, new_lines)
  local s = sym.range.start.line
  local e = sym.range["end"].line
  -- nvim_buf_set_lines end is exclusive, so e + 1 covers the full inclusive range
  vim.api.nvim_buf_set_lines(bufnr, s, e + 1, false, new_lines)
end

return M
