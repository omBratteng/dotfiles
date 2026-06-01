return {
  -- disable LazyVim's default Kotlin LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        kotlin_language_server = { enabled = false },
      },
    },
  },

  -- don't let Mason auto-install the old kotlin-language-server
  -- {
  --   "mason-org/mason.nvim",
  --   opts = function(_, opts)
  --     opts.ensure_installed = opts.ensure_installed or {}
  --     for i, v in ipairs(opts.ensure_installed) do
  --       if v == "kotlin-language-server" then
  --         table.remove(opts.ensure_installed, i)
  --         break
  --       end
  --     end
  --   end,
  -- },

  -- use kotlin.nvim with JetBrains' kotlin-lsp
  {
    "AlexandrosAlexiou/kotlin.nvim",
    ft = { "kotlin" },
    dependencies = {
      "mason.nvim",
      "mason-lspconfig.nvim",
      "stevearc/oil.nvim",
      "trouble.nvim",
    },
    config = function()
      -- local java_home = "/opt/homebrew/opt/sdkman-cli/libexec/candidates/java/25.0.3-tem"

      require("kotlin").setup({
        root_markers = { "gradlew", ".git", "mvnw", "settings.gradle" },

        jdk_for_symbol_resolution = nil,
        jre_path = nil, -- only used by legacy kotlin-lsp builds

        jvm_args = { "-Xmx4g" },
        inlay_hints = { enabled = true },
        folding = { enabled = true },
      })
    end,
  },
}
