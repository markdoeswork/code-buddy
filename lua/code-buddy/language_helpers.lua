-- Per-filetype language configuration used across the plugin.
-- Add new entries here when adding language support.

local M = {}

-- Treesitter node type names that represent functions/methods.
M.function_node_types = {
  lua = {
    function_definition = true,
    function_declaration = true,
  },
  go = {
    function_declaration = true,
    method_declaration = true,
  },
  ruby = {
    method = true,
    singleton_method = true,
    lambda = true,
  },
  javascript = {
    function_declaration = true,
    function_expression = true,
    arrow_function = true,
    method_definition = true,
  },
  typescript = {
    function_declaration = true,
    function_expression = true,
    arrow_function = true,
    method_definition = true,
  },
  python = {
    function_definition = true,
  },
  php = {
    function_definition = true,
    method_declaration = true,
    arrow_function = true,
  },
  c = {
    function_definition = true,
  },
  cpp = {
    function_definition = true,
    function_declarator = true,
    lambda_expression = true,
  },
  html = {
    script_element = true,
  },
  css = {
    -- CSS has no functions; rule_set is the closest enclosing scope
    rule_set = true,
  },
  rust = {
    function_item = true,
    closure_expression = true,
  },
  java = {
    method_declaration = true,
    lambda_expression = true,
  },
}

-- Comment prefix strings used when injecting virtual comment lines.
M.comment_prefix = {
  lua        = "-- ",
  go         = "// ",
  ruby       = "# ",
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