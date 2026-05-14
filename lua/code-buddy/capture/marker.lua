local M = {}

-- Scan the buffer for a line containing "--buddy" (anywhere in the line,
-- works regardless of comment style or surrounding text).
-- Returns the 0-indexed row of the first match, or nil if not found.
function M.find(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for i, line in ipairs(lines) do
    if line:find("--buddy", 1, true) then
      return i - 1  -- 0-indexed
    end
  end
  return nil
end

return M
