return {
  {
    "petertriho/nvim-scrollbar",
    lazy = false,
    opts = {
      -- A clearly visible, slim viewport indicator.
      set_highlights = false,
      handle = {
        text = "▎",
        blend = 0,
      },
      handlers = {
        cursor = false,
        diagnostic = false,
        gitsigns = false,
        search = false,
        ale = false,
        handle = true,
      },
    },
    config = function(_, opts)
      require("scrollbar").setup(opts)

      local function set_scrollbar_highlight()
        vim.cmd("highlight ScrollbarHandle guifg=#89b4fa guibg=NONE ctermfg=LightBlue ctermbg=NONE")
      end

      set_scrollbar_highlight()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = set_scrollbar_highlight,
      })
    end,
  },
}
