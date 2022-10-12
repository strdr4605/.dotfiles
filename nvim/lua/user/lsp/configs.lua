local status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status_ok then
  return
end

require("lua-dev").setup({
  -- add any options here, or leave empty to use the default settings
})

local mason = require("mason")
local lspconfig = require("lspconfig")

local servers = { "jsonls", "sumneko_lua", "tsserver", "eslint", "cssls" }

mason.setup()
mason_lspconfig.setup({
  ensure_installed = servers,
})

for _, server in pairs(servers) do
  local opts = {
    on_attach = require("user.lsp.handlers").on_attach,
    capabilities = require("user.lsp.handlers").capabilities,
  }
  local has_custom_opts, server_custom_opts = pcall(require, "user.lsp.settings." .. server)
  if has_custom_opts then
    opts = vim.tbl_deep_extend("force", opts, server_custom_opts)
  end
  -- add a special case for tsserver, since we want to go through typescript.nvim here
  if server == "tsserver" then
    -- https://github.com/jose-elias-alvarez/typescript.nvim
    require("typescript").setup({ server = opts })
  else
    lspconfig[server].setup(opts)
  end
end
