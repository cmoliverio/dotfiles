return {
  {
    "tadaa/vimade",
    event = "VeryLazy",
    opts = {
      -- Fade every Neovim highlight when this tmux pane loses focus.
      enablefocusfading = true,
      fadelevel = 0.8,

      -- Blend toward cool slate grays instead of Rosé Pine's warmer base.
      -- This applies to syntax colors and UI panes such as the file explorer.
      basebg = "#1f252d",
      tint = {
        fg = { rgb = { 116, 134, 156 }, intensity = 0.5 },
        bg = { rgb = { 31, 37, 45 }, intensity = 0.25 },
        sp = { rgb = { 116, 134, 156 }, intensity = 0.5 },
      },

      -- Snacks implements its explorer as a picker window. Allow that one
      -- tagged list buffer to fade, while retaining Vimade's protection for
      -- file-search prompts and all other floating picker windows.
      blocklist = {
        block_inactive_floats = function(win, active)
          if win.buf_vars.vimade_snacks_explorer then
            return false
          end
          return win.win_config.relative ~= ""
            and (win ~= active or win.buf_opts.buftype == "terminal")
        end,
      },

      recipe = { "default", { animate = false } },
    },
  },
}
