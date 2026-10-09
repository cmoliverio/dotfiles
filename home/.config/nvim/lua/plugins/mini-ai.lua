return {
  {
    "nvim-mini/mini.ai",
    opts = function(_, opts)
      local pair = require("mini.ai").gen_spec.pair

      opts.custom_textobjects = opts.custom_textobjects or {}
      opts.custom_textobjects["*"] = pair("*", "*", { type = "greedy" })

      return opts
    end,
  },
}
