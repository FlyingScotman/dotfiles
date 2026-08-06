local M = {}

function M.is_network_path(path)
  if not path or path == "" then
    return false
  end

  local normalized = path:gsub("/", "\\")
  if normalized:match("^\\\\") then
    return true
  end

  local drive = normalized:match("^([A-Za-z]):\\")
  return drive ~= nil and drive:upper() == "G"
end

function M.is_network_buffer(bufnr)
  bufnr = bufnr or 0
  return M.is_network_path(vim.api.nvim_buf_get_name(bufnr))
end

return M
