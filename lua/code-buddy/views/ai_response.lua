-- Orchestrates the --ai flow:
--   1. Build prompt from marker question + collected meta lines
--   2. Start loading spinner
--   3. Call the API
--   4. Stop spinner, inject AI reply as comments

local api      = require("code-buddy.ai_api.api")
local prompt   = require("code-buddy.ai_api.prompt")
local loading  = require("code-buddy.views.virtual_text.loading")
local injector = require("code-buddy.commentor.injector")

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

return M
