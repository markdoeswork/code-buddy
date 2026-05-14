local M = {}

function M.show(bufnr, ns, row, chunks)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, row, row + 1)
  vim.api.nvim_buf_set_extmark(bufnr, ns, row, 0, {
    virt_text = chunks,
    virt_text_pos = "eol",
  })
end

function M.clear(bufnr, ns)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

return M
