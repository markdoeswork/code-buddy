local M = {}

function M.setup()
  vim.api.nvim_create_user_command("CodeBuddy", function()
    print(vim.api.nvim_buf_get_name(0))
  end, {})

  vim.api.nvim_create_user_command("CodeBuddySpinner", require("code-buddy.commands.spinner"), {})
  vim.api.nvim_create_user_command("CodeBuddyMeta", require("code-buddy.commands.meta_data"), {})
  vim.api.nvim_create_user_command("CodeBuddyClear", function()
    require("code-buddy.commentor.injector").clear(vim.api.nvim_get_current_buf())
  end, {})
end

return M
