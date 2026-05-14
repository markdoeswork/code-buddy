local M = {}

-- Walk documentSymbol results (nested) to find the innermost symbol
-- whose range contains `row` (0-indexed). Method/function kinds only.
-- SymbolKind 6 = Method, 12 = Function
local FUNCTION_KINDS = { [6] = true, [12] = true }

local function find_enclosing_symbol(symbols, row)
  local best = nil
  for _, sym in ipairs(symbols) do
    local sr = sym.range.start.line
    local er = sym.range["end"].line
    if sr <= row and row <= er then
      if FUNCTION_KINDS[sym.kind] then
        -- Take the innermost (smallest range)
        if not best or (er - sr) < (best.range["end"].line - best.range.start.line) then
          best = sym
        end
      end
      -- Recurse into children regardless of kind (e.g. class contains methods)
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
function M.get_enclosing_function(bufnr, row, callback)
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

-- Strip markdown formatting (backticks, bold, italic) from LSP hover text
local function strip_markdown(s)
  if not s then return s end
  s = s:gsub("```[^\n]*\n(.-)```", "%1")  -- fenced code blocks
  s = s:gsub("`([^`]+)`", "%1")            -- inline code
  s = s:gsub("%*%*(.-)%*%*", "%1")         -- bold
  s = s:gsub("%*(.-)%*", "%1")             -- italic
  return s:match("^%s*(.-)%s*$")           -- trim whitespace
end

-- Returns LSP metadata for a symbol, querying at fn_pos (the function name location)
-- and collecting diagnostics across the full function range [diag_start_row, diag_end_row].
-- callback(info) where info = {
--   available = bool,
--   signature = string|nil,    -- hover text (type/signature of the method)
--   ref_count = number|nil,    -- total callers across all files
--   diagnostics = [{severity, message}],
-- }
function M.get_info(bufnr, fn_pos, diag_range, callback)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if not clients or #clients == 0 then
    callback({ available = false, diagnostics = {} })
    return
  end

  -- Collect diagnostics for the whole function range
  local diag_info = {}
  local severity_labels = { "ERROR", "WARN", "INFO", "HINT" }
  if diag_range then
    for lnum = diag_range.start_row, diag_range.end_row do
      local diags = vim.diagnostic.get(bufnr, { lnum = lnum })
      for _, d in ipairs(diags) do
        table.insert(diag_info, {
          severity = severity_labels[d.severity] or "?",
          message = d.message,
        })
      end
    end
  end

  local lsp_pos = { line = fn_pos.row, character = fn_pos.col }
  local params = {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    position = lsp_pos,
  }

  local results = { available = true, diagnostics = diag_info }
  local pending = 2

  local function done()
    pending = pending - 1
    if pending == 0 then
      callback(results)
    end
  end

  -- Hover at the function name gives its signature
  local ok_hover = vim.lsp.buf_request(bufnr, "textDocument/hover", params, function(_, hover_result)
    if hover_result and hover_result.contents then
      local contents = hover_result.contents
      local raw
      if type(contents) == "table" and contents.value then
        raw = contents.value:match("^[^\n]+")
      elseif type(contents) == "string" then
        raw = contents:match("^[^\n]+")
      end
      results.signature = strip_markdown(raw)
    end
    done()
  end)
  if not ok_hover then done() end

  -- References at the function name = all callers across the project
  local ref_params = {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    position = lsp_pos,
    context = { includeDeclaration = false },
  }
  local ok_refs = vim.lsp.buf_request(bufnr, "textDocument/references", ref_params, function(_, ref_result)
    results.ref_count = ref_result and #ref_result or nil
    done()
  end)
  if not ok_refs then done() end
end

return M
