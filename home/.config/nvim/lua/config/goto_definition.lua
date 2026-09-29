local M = {}

local function as_locations(result)
  if result == nil then
    return nil
  end
  if vim.islist(result) then
    return #result > 0 and result or nil
  end
  return { result }
end

local function tags_or_grep()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    return
  end

  local pattern = "^" .. vim.fn.escape(word, [[\.^$~[]]) .. "$"
  if #vim.fn.taglist(pattern) > 0 then
    Snacks.picker.tags({ pattern = word })
  else
    Snacks.picker.grep_word()
  end
end

function M.goto_definition()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({
    bufnr = bufnr,
    method = "textDocument/definition",
  })

  for _, client in ipairs(clients) do
    local encoding = client.offset_encoding or "utf-16"
    local params = vim.lsp.util.make_position_params(0, encoding)
    local response = client:request_sync(
      "textDocument/definition",
      params,
      1000,
      bufnr
    )
    local locations = response and as_locations(response.result)

    if locations then
      vim.cmd("normal! m'")
      if #locations == 1 then
        vim.lsp.util.show_document(locations[1], encoding, {
          focus = true,
          reuse_win = true,
        })
      else
        local items = vim.lsp.util.locations_to_items(locations, encoding)
        vim.fn.setqflist({}, " ", {
          title = "LSP definitions",
          items = items,
        })
        vim.cmd("botright copen")
      end
      return
    end
  end

  tags_or_grep()
end

return M
