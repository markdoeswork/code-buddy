-- Per-filetype comment prefix strings used when injecting comment lines.
-- Add new entries here when adding language support.

local M = {}

M.comment_prefix = {
  lua        = "-- ",
  go         = "// ",
  ruby       = "# ",
  eruby      = "# ",
  javascript = "// ",
  typescript = "// ",
  python     = "# ",
  php        = "// ",
  c          = "// ",
  cpp        = "// ",
  html       = "<!-- ",
  css        = "/* ",
  rust       = "// ",
  java       = "// ",
}

function M.get_comment_prefix(bufnr)
  local ft = vim.bo[bufnr].filetype
  return M.comment_prefix[ft] or "-- "
end

return M
