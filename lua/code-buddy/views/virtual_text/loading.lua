-- Animated "Thinking." spinner shown at EOL while waiting for the AI response.
-- Uses a uv timer so it doesn't block.

local M = {}

local NS = vim.api.nvim_create_namespace("codebuddy-loading")
local FRAMES = { "Thinking.", "Thinking..", "Thinking..." }
local INTERVAL_MS = 400

local timers = {}  -- bufnr → uv timer handle

function M.start(bufnr, row)
  M.stop(bufnr)

  local frame = 1
  local timer = vim.uv.new_timer()

  timer:start(0, INTERVAL_MS, vim.schedule_wrap(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      M.stop(bufnr)
      return
    end
    vim.api.nvim_buf_clear_namespace(bufnr, NS, row, row + 1)
    vim.api.nvim_buf_set_extmark(bufnr, NS, row, 0, {
      virt_text = { { FRAMES[frame], "DiagnosticHint" } },
      virt_text_pos = "eol",
    })
    frame = (frame % #FRAMES) + 1
  end))

  timers[bufnr] = { timer = timer, row = row }
end

function M.stop(bufnr)
  local entry = timers[bufnr]
  if not entry then return end
  entry.timer:stop()
  entry.timer:close()
  timers[bufnr] = nil
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)
  end
end

return M
