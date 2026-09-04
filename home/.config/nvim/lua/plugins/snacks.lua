return {
  "folke/snacks.nvim",
  opts = {
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
      sources = {
        files = {
          hidden = true,
          ignored = true,
          exclude = { ".git" },
        },
      },
    },
  },
}
