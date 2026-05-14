local lsp_capture = require("code-buddy.capture.lsp")
local marker = require("code-buddy.capture.marker")
local injector = require("code-buddy.commentor.injector")

local M = {}

function M.show(bufnr, row, col)
  local marker_row = marker.find(bufnr)
  if marker_row then
    row = marker_row
    col = 0
  end

  -- Step 1: find enclosing function via documentSymbol
  lsp_capture.get_enclosing_function(bufnr, row, function(sym)
    -- Step 2: gather hover + refs + diagnostics
    local fn_pos, diag_range
    if sym then
      -- Target the name token: selectionRange is exactly the symbol name span
      fn_pos = {
        row = sym.selectionRange.start.line,
        col = sym.selectionRange.start.character,
      }
      diag_range = {
        start_row = sym.range.start.line,
        end_row   = sym.range["end"].line,
      }
    else
      fn_pos    = { row = row, col = col }
      diag_range = nil
    end

    lsp_capture.get_info(bufnr, fn_pos, diag_range, function(lsp_info)
      local lines = {}

      if sym then
        lines[#lines + 1] = "function: " .. sym.name
          .. "  [lines " .. (sym.range.start.line + 1) .. "–" .. (sym.range["end"].line + 1) .. "]"
      else
        lines[#lines + 1] = "function: <none>"
      end

      if lsp_info.available then
        if lsp_info.signature and lsp_info.signature ~= "" then
          lines[#lines + 1] = "signature: " .. lsp_info.signature
        end

        if lsp_info.ref_count ~= nil then
          local label = lsp_info.ref_count == 1 and "caller" or "callers"
          lines[#lines + 1] = "refs: " .. lsp_info.ref_count .. " " .. label
        end

        for _, d in ipairs(lsp_info.diagnostics) do
          lines[#lines + 1] = d.severity .. ": " .. d.message
        end
      else
        lines[#lines + 1] = "lsp: not attached"
      end

      injector.inject(bufnr, row, lines, { label = "meta" })
    end)
  end)
end

return M
