return {
  {
    "ludovicchabant/vim-gutentags",
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      vim.g.gutentags_modules = { "ctags" }
      vim.g.gutentags_ctags_executable = vim.fn.expand("~/.local/bin/ctags")
      vim.g.gutentags_cache_dir = vim.fn.stdpath("cache") .. "/gutentags"

      -- TEST_SETUP.sh keeps verification-test tags focused on verif_tests.
      -- Other repositories continue to use their nearest .git directory.
      vim.g.gutentags_project_root = { "TEST_SETUP.sh", ".git" }
      vim.g.gutentags_add_default_project_roots = 0

      vim.g.gutentags_generate_on_missing = 1
      vim.g.gutentags_generate_on_new = 1
      vim.g.gutentags_generate_on_write = 1
      vim.g.gutentags_generate_on_empty_buffer = 0

      vim.g.gutentags_ctags_extra_args = {
        "--fields=+niazS",
        "--extras=+q",
      }
      vim.g.gutentags_ctags_exclude = {
        ".git",
        ".git/*",
        "_workspace",
        "_workspace/*",
        "_logs",
        "_logs/*",
        "artifacts",
        "artifacts/*",
        "logs",
        "logs/*",
        "vcp",
        "vcp/*",
        "obj",
        "obj/*",
      }
    end,
  },
}
