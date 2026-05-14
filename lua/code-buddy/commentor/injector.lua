local vt_lines = require("code-buddy.views.virtual_text.lines")
local hl = require("code-buddy.views.virtual_text.highlight")

local M = {}

local ns = vim.api.nvim_create_namespace("code_buddy_commentor")

local lang = require("code-buddy.language_helpers")

function M.inject(bufnr, row, comment_lines, opts)
  local prefix = lang.get_comment_prefix(bufnr)
  local label = opts and opts.label or "codebuddy"

  local lines_chunks = {}

  table.insert(lines_chunks, { { prefix .. "codebuddy: " .. label, hl.header } })

  for _, line in ipairs(comment_lines) do
    table.insert(lines_chunks, { { prefix .. line, hl.comment } })
  end

  vt_lines.show(bufnr, ns, row, lines_chunks)
end

function M.clear(bufnr)
  vt_lines.clear(bufnr, ns)
end

return M
