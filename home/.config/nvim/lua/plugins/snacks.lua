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
          layout = {
            layout = {
              width = 46,
              min_width = 46,
            },
          },
          win = {
            list = {
              -- Override Snacks' list-down mapping; `on_show` below maps it
              -- directly to tmux's pane below.
              keys = {
                ["<C-j>"] = false,
              },
              wo = {
                number = true,
                relativenumber = true,
              },
            },
          },
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

            -- The explorer and editor are side-by-side. Neovim's `wincmd j`
            -- can incorrectly select that editor window, so go directly to
            -- tmux's pane below from the explorer.
            vim.keymap.set("n", "<C-j>", function()
              if vim.env.TMUX_PANE then
                vim.fn.system({ "tmux", "select-pane", "-t", vim.env.TMUX_PANE, "-D" })
              end
            end, { buffer = picker.list.win.buf, silent = true })
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
