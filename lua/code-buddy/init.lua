local M = {}

function M.setup(opts)
  local config = require("code-buddy.config")
  config.api_key = (opts and opts.api_key) or ""

  vim.api.nvim_create_user_command("CodeBuddy", function()
    print(vim.api.nvim_buf_get_name(0))
  end, {})

  vim.api.nvim_create_user_command("CodeBuddyMeta", require("code-buddy.commands.meta_data"), {})
  vim.api.nvim_create_user_command("CodeBuddyClear", function()
    require("code-buddy.commentor.injector").clear(vim.api.nvim_get_current_buf())
  end, {})
end

return M
