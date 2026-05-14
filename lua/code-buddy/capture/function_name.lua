local M = {}

-- SymbolKind 6 = Method, 12 = Function
local FUNCTION_KINDS = { [6] = true, [12] = true }

local function find_enclosing_symbol(symbols, row)
  local best = nil
  for _, sym in ipairs(symbols) do
    local sr = sym.range.start.line
    local er = sym.range["end"].line
    if sr <= row and row <= er then
      if FUNCTION_KINDS[sym.kind] then
        if not best or (er - sr) < (best.range["end"].line - best.range.start.line) then
          best = sym
        end
      end
      if sym.children then
        local child = find_enclosing_symbol(sym.children, row)
        if child then
          local csr = child.range.start.line
          local cer = child.range["end"].line
          if not best or (cer - csr) < (best.range["end"].line - best.range.start.line) then
            best = child
          end
        end
      end
    end
  end
  return best
end

-- Find the enclosing function/method for `row` (0-indexed) via documentSymbol.
-- callback(sym) where sym is the LSP DocumentSymbol, or nil if not found.
function M.get(bufnr, row, callback)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if not clients or #clients == 0 then
    callback(nil)
    return
  end

  local params = { textDocument = { uri = vim.uri_from_bufnr(bufnr) } }
  local ok = vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", params, function(_, result)
    if not result then callback(nil); return end
    callback(find_enclosing_symbol(result, row))
  end)
  if not ok then callback(nil) end
end

return M
