return function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  require("code-buddy.views.meta_data").show(bufnr, cursor[1] - 1, cursor[2])
end
