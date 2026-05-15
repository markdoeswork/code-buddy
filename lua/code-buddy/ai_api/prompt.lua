-- Builds the prompt string sent to the AI.
-- Combines the user's question (from the marker line) with the
-- already-collected metadata lines (function info, code, diagnostics, etc).

local M = {}

-- marker_line: the raw line containing --buddy, e.g. "# --buddy fix this  --function"
-- meta_lines:  table of strings already assembled by views/meta_data (the comment content)
-- Returns a single prompt string.
function M.build(marker_line, meta_lines)
  -- Extract the human question: everything between --buddy and the first --flag
  local question = marker_line:match("%-%-buddy%s+(.-)%s*%-%-") or
                   marker_line:match("%-%-buddy%s+(.+)$") or ""
  question = question:gsub("^%s+", ""):gsub("%s+$", "")

  local parts = {}

  if #meta_lines > 0 then
    parts[#parts + 1] = "Context from the codebase:\n" .. table.concat(meta_lines, "\n")
  end

  if question ~= "" then
    parts[#parts + 1] = "Question: " .. question
  end

  return table.concat(parts, "\n\n")
end

return M
