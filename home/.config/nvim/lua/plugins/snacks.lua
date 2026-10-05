return {
  "folke/snacks.nvim",
  opts = {
    explorer = {
      replace_netrw = true
    },
    scroll = {
      animate = {
        duration = {
          step = 2,
          total = 40,
        },
        easing = "linear",
      },

      animate_repeat = {
        delay = 50,
        duration = {
          step = 1,
          total = 15,
        },
        easing = "linear",
      },
    },

    picker = {
      icons = {
        git = {
          untracked = "",
        },
      },
      sources = {
        explorer = {
          hidden = true,
          ignored = true,
          on_show = function(picker)
            -- Let Vimade fade the explorer without touching other Snacks
            -- pickers, especially interactive file-search prompts.
            vim.b[picker.list.win.buf].vimade_snacks_explorer = true
          end,
        },
        files = {
          hidden = true,
          ignored = true,
          exclude = { ".git" },
        },
      },
    },
  },
}
