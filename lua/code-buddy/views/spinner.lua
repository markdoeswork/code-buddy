local M = {}

local ns = vim.api.nvim_create_namespace("code_buddy_spinner")

function M.show(line, message, seconds, on_done)
  local bufnr = vim.api.nvim_get_current_buf()
  local remaining = seconds or 5
  local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
  local frame_idx = 1
  local timer = vim.uv.new_timer()

  local function render()
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    vim.api.nvim_buf_set_extmark(bufnr, ns, line - 1, 0, {
      virt_text = { { frames[frame_idx] .. " " .. message .. " (" .. remaining .. "s)", "DiagnosticInfo" } },
      virt_text_pos = "eol",
    })
    frame_idx = (frame_idx % #frames) + 1
  end

  local ticks = 0
  render()

  timer:start(100, 100, vim.schedule_wrap(function()
    ticks = ticks + 1
    if ticks % 10 == 0 then
      remaining = remaining - 1
    end

    if remaining <= 0 then
      timer:stop()
      timer:close()
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
      if on_done then on_done() end
      return
    end

    render()
  end))
end

return M
