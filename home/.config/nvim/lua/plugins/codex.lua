return {
  {
    "yaadata/codex.nvim",
    url = "https://codeberg.org/yaadata/codex.nvim.git",
    version = "1.0.0",
    cmd = {
      "Codex",
      "CodexFocus",
      "CodexClose",
      "CodexSendSelection",
      "CodexSendFile",
      "CodexMentionFile",
      "CodexMentionDirectory",
      "CodexResume",
    },
    opts = {
      launch = {
        cmd = "codex",
        auto_start = true,
        cwd = nil,
      },

      terminal = {
        provider = "auto",

        provider_opts = {
          native = {
            window = "vsplit",

            vsplit = {
              side = "right",
              size_pct = 40,
            },
          },
        },
      },
    },
  },
}
