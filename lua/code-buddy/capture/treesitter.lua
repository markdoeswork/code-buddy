local M = {}

local function_node_types = require("code-buddy.language_helpers").function_node_types

function M.get_enclosing_function(bufnr, row, col)
  local ft = vim.bo[bufnr].filetype
  local types = function_node_types[ft]
  if not types then return nil end

  local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { row, col } })
  if not node then return nil end

  while node do
    if types[node:type()] then
      local name_node = node:named_child(0)
      local name = name_node and vim.treesitter.get_node_text(name_node, bufnr) or "<anonymous>"
      local sr, _, er, _ = node:range()
      return { name = name, node = node, start_row = sr, end_row = er }
    end
    node = node:parent()
  end

  return nil
end

return M
