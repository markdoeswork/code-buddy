local M = {}

-- Scan the buffer for a line containing "--buddy" (anywhere in the line,
-- works regardless of comment style or surrounding text).
-- Returns the 0-indexed row of the first match, or nil if not found.
-- Also returns a table of flags parsed from the marker line (e.g. "--code").
function M.find(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for i, line in ipairs(lines) do
    if line:find("--buddy", 1, true) then
      local flags = {}
      for flag in line:gmatch("%-%-(%a+)") do
        flags[flag] = true
      end
      flags.buddy = nil  -- remove the marker itself
      return i - 1, flags  -- 0-indexed row, flags table
    end
  end
  return nil, {}
end

return M
