return {
  cmd = { "vtsls", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
  single_file_support = true,
  settings = {
    typescript = {
      updateImportsOnFileMove = "always",
      tsserver = {
        -- try to fix "The JS/TS language service crashed 5 times in the last 5 Minutes."
        -- https://github.com/yioneko/nvim-vtsls/issues/15
        maxTsServerMemory = 8192, -- Increase memory limit (e.g., 8GB)
      },
    },
    javascript = {
      updateImportsOnFileMove = "always",
    },
    vtsls = {
      enableMoveToFileCodeAction = true,
    },
  },
}
