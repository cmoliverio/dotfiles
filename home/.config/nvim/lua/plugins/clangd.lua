return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
          },
          keys = {
            {
              "gd",
              function()
                require("config.goto_definition").goto_definition()
              end,
              desc = "Goto Definition (LSP, tags, or grep)",
            },
          },
        },
      },
    },
  },
}
