local setup = function()
  local config = {
    virtual_text = false,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(config)

  vim.lsp.handlers["textDocument/hover"] =
  vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

  vim.lsp.handlers["textDocument/signatureHelp"] =
  vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end

setup()

require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = {
    "jsonls",
    "lua_ls",
    "tsserver",
    "cssls",
    "emmet_ls",
    "eslint",
  },
})

local null_ls = require("null-ls")
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
null_ls.setup({
  debug = false,
  sources = {
    formatting.shfmt.with({
      extra_args = { "-i", "2", "-ci" },
    }),
    formatting.prettier.with({
      prefer_local = "node_modules/.bin",
    }),
    formatting.stylua,
    -- https://github.com/jose-elias-alvarez/typescript.nvim
    require("typescript.extensions.null-ls.code-actions"),
  },
})
require("mason-null-ls").setup({
  ensure_installed = nil,
  automatic_installation = true,
  automatic_setup = false,
})

local lsp_attach = function(_, bufnr)
  local opts = { buffer = bufnr, remap = false, silent = true }
  vim.keymap.set("n", "gd", function()
    vim.lsp.buf.definition()
  end, opts)
  vim.keymap.set("n", "gr", function()
    vim.lsp.buf.references()
  end, opts)
  vim.keymap.set("n", "gl", function()
    vim.diagnostic.open_float()
  end, opts)
  vim.keymap.set("n", "K", function()
    vim.lsp.buf.hover()
  end, opts)
  vim.keymap.set("n", "<C-k>", function()
    vim.lsp.buf.signature_help()
  end, opts)
  vim.keymap.set("n", "<leader>rn", function()
    vim.lsp.buf.rename()
  end, opts)
  vim.keymap.set("n", "<leader>ca", function()
    vim.lsp.buf.code_action()
  end, opts)
  vim.keymap.set("n", "[d", function()
    vim.diagnostic.goto_prev({ border = "rounded" })
  end, opts)
  vim.keymap.set("n", "]d", function()
    vim.diagnostic.goto_next({ border = "rounded" })
  end, opts)
  vim.keymap.set("n", "<leader>q", function()
    vim.diagnostic.setloclist()
  end, opts)

  vim.api.nvim_create_user_command("F", function()
    vim.lsp.buf.format({ async = true })
  end, {})
end
local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

local lspconfig = require("lspconfig")
require("mason-lspconfig").setup_handlers({
  function(server_name)
    local opts = {
      on_attach = lsp_attach,
      capabilities = lsp_capabilities,
    }

    local has_custom_opts, server_custom_opts =
    pcall(require, "strdr4605.lsp_server_settings." .. server_name)
    if has_custom_opts then
      opts = vim.tbl_deep_extend("force", opts, server_custom_opts)
    end

    -- add a special case for tsserver, since we want to go through typescript.nvim here
    if server_name == "tsserver" then
      -- https://github.com/jose-elias-alvarez/typescript.nvim
      require("typescript").setup({ server = opts })
    else
      lspconfig[server_name].setup(opts)
    end
  end,
})