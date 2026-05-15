-- Cleans raw LLM response text into a table of code lines.
-- Handles Qwen3 <think> blocks, markdown fences, and blank line trimming.

local M = {}

local function trim_blank_lines(lines)
  local first, last = 1, #lines
  while first <= last and lines[first]:match("^%s*$") do first = first + 1 end
  while last >= first and lines[last]:match("^%s*$") do last = last - 1 end
  local result = {}
  for i = first, last do result[#result + 1] = lines[i] end
  return result
end

-- Returns a table of clean code lines extracted from the LLM response.
-- Fallback: if nothing usable is found, returns { response_text } so the
-- caller can detect failure rather than silently deleting the function.
function M.extract(response_text)
  local text = response_text

  -- Strip Qwen3 chain-of-thought block (emitted before the actual answer)
  text = text:gsub("<think>.-</think>%s*", "")

  -- Extract content from a fenced code block if present
  local fenced = text:match("```[^\n]*\n(.-)\n```")
  if fenced then
    text = fenced
  end

  local lines = vim.split(text, "\n", { plain = true })
  local result = trim_blank_lines(lines)

  if #result == 0 then
    return { response_text }
  end

  return result
end

return M
