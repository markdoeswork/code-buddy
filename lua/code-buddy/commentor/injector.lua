local M = {}

local lang = require("code-buddy.language_helpers")

-- Marker added to injected comment lines so we can find and remove them later
local MARKER = "codebuddy-injected"

function M.inject(bufnr, row, comment_lines, opts)
  local prefix = lang.get_comment_prefix(bufnr)
  local label = opts and opts.label or "codebuddy"

  local lines = {}
  table.insert(lines, prefix .. "codebuddy: " .. label .. "  [" .. MARKER .. "]")
  for _, line in ipairs(comment_lines) do
    table.insert(lines, prefix .. line)
  end

  -- Insert above the cursor row (row is 0-indexed, nvim_buf_set_lines uses 0-indexed)
  vim.api.nvim_buf_set_lines(bufnr, row, row, false, lines)
end

function M.clear(bufnr)
  local all_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local to_delete = {}

  local i = 1
  while i <= #all_lines do
    if all_lines[i]:find(MARKER, 1, true) then
      -- Find the header line, then collect all following comment lines
      local block_start = i - 1  -- 0-indexed
      local prefix = lang.get_comment_prefix(bufnr)
      local j = i + 1
      while j <= #all_lines and all_lines[j]:match("^%s*" .. vim.pesc(prefix)) and not all_lines[j]:find(MARKER, 1, true) do
        j = j + 1
      end
      table.insert(to_delete, { block_start, j - 1 })  -- 0-indexed start, end (exclusive)
      i = j
    else
      i = i + 1
    end
  end

  -- Delete in reverse order so line numbers stay valid
  for k = #to_delete, 1, -1 do
    local s, e = to_delete[k][1], to_delete[k][2]
    vim.api.nvim_buf_set_lines(bufnr, s, e, false, {})
  end
end

return M
