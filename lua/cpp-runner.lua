local M = {}

function project_name()
  local name = vim.api.nvim_buf_get_name(0)
  if vim.endswith(name, ".cpp") == false and vim.endswith(name, ".in") == false and vim.endswith(name, ".out") == false then
    return nil
  end
  return vim.split(name, ".", { plain = true })[1]
end

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
  local name = project_name()
  if name == nil then
    return
  end

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

M.run_proj = function()
  local name = project_name()
  if name == nil then
    return
  end
  local name_s = vim.split(name, "/", { plain = true })
  name = name_s[#name_s]

  local curl = require("plenary.curl")
  local res = curl.post("localhost:42069/run/" .. name)
  print(vim.inspect(res))

  if res.status ~= 200 then
    print("Error running project. Is the server running?")
    print("Error: " .. res.body)
  end
end

return M
