local M = {}

function M.setup()
  vim.api.nvim_create_user_command("CodeBuddy", function()
    print(vim.api.nvim_buf_get_name(0))
  end, {})
end

return M
