return {
  {
    "folke/flash.nvim",
    keys = function(_, keys)
      for _, key in ipairs(keys) do
        if key[1] == "s" then
          key.mode = "o"
          break
        end
      end
      keys[#keys + 1] = {
        "<leader>j",
        function()
          require("flash").jump()
        end,
        mode = { "n", "x" },
        desc = "Flash Jump",
      }
      return keys
    end,
  },
  {
    "kylechui/nvim-surround",
    version = "^4.0.0",
    event = "VeryLazy",
    init = function()
      vim.g.nvim_surround_no_normal_mappings = true
      vim.g.nvim_surround_no_visual_mappings = true
    end,
    keys = {
      { "sa", "<Plug>(nvim-surround-visual)", mode = "x", desc = "Add surround" },
      { "sd", "<Plug>(nvim-surround-delete)", mode = "n", desc = "Delete surround" },
      { "sr", "<Plug>(nvim-surround-change)", mode = "n", desc = "Change surround" },
    },
    opts = {},
  },
}
