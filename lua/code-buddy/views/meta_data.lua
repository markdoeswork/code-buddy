local ts_capture = require("code-buddy.capture.treesitter")
local injector = require("code-buddy.commentor.injector")

local M = {}

function M.show(bufnr, row, col)
  local fn = ts_capture.get_enclosing_function(bufnr, row, col)

  if not fn then
    injector.inject(bufnr, row, { "cursor not inside a function" }, { label = "meta" })
    return
  end

  local lines = {
    "function: " .. fn.name .. "()  [lines " .. (fn.start_row + 1) .. "–" .. (fn.end_row + 1) .. "]",
  }

  injector.inject(bufnr, row, lines, { label = "meta" })
end

return M
