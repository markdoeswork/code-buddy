local spinner_view = require("code-buddy.views.spinner")

return function()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  spinner_view.show(line, "Loading...", 5)
end
