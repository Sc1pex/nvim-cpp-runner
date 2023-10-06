local M = {}

M.fstream_proj = function()
  vim.ui.input({ prompt = "Fstream project name" },
    function(input)
      if input == nil then
        return
      end

      local cmd = "proj_gen f " .. input
      os.execute(cmd)
      local file = "e " .. input .. "/" .. input
      vim.cmd(file .. ".in")
      vim.cmd(file .. ".out")
      vim.cmd(file .. ".cpp")
    end
  )
end

M.istream_proj = function()
  vim.ui.input({ prompt = "Iostream project name" },
    function(input)
      if input == nil then
        return
      end

      local cmd = "proj_gen i " .. input
      os.execute(cmd)
      local file = "e " .. input .. "/" .. input
      vim.cmd(file .. ".cpp")
    end
  )
end

M.close_proj = function()
  local name = vim.split(vim.api.nvim_buf_get_name(0), ".", { plain = true })[1]
  print(name)
  for _, v in ipairs(vim.api.nvim_list_bufs()) do
    local buf_name = vim.api.nvim_buf_get_name(v)
    if vim.startswith(buf_name, name) then
      vim.api.nvim_buf_delete(v, { force = false })
    end
  end
end

M.open_proj = function()
  vim.ui.input({ prompt = "Project name" },
    function(input)
      if input == nil then
        return
      end

      local function openfile(path)
        if vim.fn.filereadable(path) == 1 then
          vim.cmd("e " .. path)
        end
      end

      local path = vim.fn.getcwd() .. "/" .. input .. "/" .. input
      openfile(path .. ".cpp")
      openfile(path .. ".in")
      openfile(path .. ".out")
    end
  )
end

return M
