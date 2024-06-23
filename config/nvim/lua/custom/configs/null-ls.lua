-- ~/.config/nvim/lua/custom/configs/null-ls.lua

local null_ls = require("null-ls")

local sources = {
  null_ls.builtins.formatting.black,
  null_ls.builtins.diagnostics.flake8,
  null_ls.builtins.formatting.clang_format,
  null_ls.builtins.formatting.shfmt,
  null_ls.builtins.diagnostics.shellcheck,
}

null_ls.setup {
  sources = sources,
  on_attach = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_command [[augroup Format]]
      vim.api.nvim_command [[autocmd! * <buffer>]]
      vim.api.nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format({ bufnr = bufnr })]]
      vim.api.nvim_command [[augroup END]]
    end
  end,
}

