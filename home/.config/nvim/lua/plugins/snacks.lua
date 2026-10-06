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

            -- Keep the selected tree item visible when deeply indented by
            -- highlighting its entire row.
            vim.api.nvim_set_hl(0, "SnacksPickerListCursorLine", {
              bg = "#403d52",
              bold = true,
            })
            vim.wo[picker.list.win.win].cursorline = true
            vim.wo[picker.list.win.win].cursorlineopt = "line"
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
