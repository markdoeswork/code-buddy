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

-- marker_line: the raw --buddy line (for extracting the question)
-- fn_lines:    table of raw source lines of the function to rewrite
-- Returns a tight prompt that instructs the LLM to return ONLY the raw updated function.
function M.build_replace(marker_line, fn_lines)
  local question = marker_line:match("%-%-buddy%s+(.-)%s*%-%-") or
                   marker_line:match("%-%-buddy%s+(.+)$") or ""
  question = question:gsub("^%s+", ""):gsub("%s+$", "")

  return table.concat({
    "You are a code assistant. Rewrite the following function exactly as instructed.",
    "Rules:",
    "- Output ONLY the raw updated function code.",
    "- Do NOT include markdown fences, backticks, or code blocks.",
    "- Do NOT include any explanation, comments, or text before or after the function.",
    "- Preserve the original indentation style exactly.",
    "- Return the complete function from its first line to its last line.",
    "",
    "Instruction: " .. question,
    "",
    "Function to rewrite:",
    table.concat(fn_lines, "\n"),
  }, "\n")
end

return M
