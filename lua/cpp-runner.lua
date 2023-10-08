local M = {}

local function project_name()
  local name = vim.api.nvim_buf_get_name(0)
  if vim.endswith(name, ".cpp") == false and vim.endswith(name, ".in") == false and vim.endswith(name, ".out") == false then
    return nil
  end
  return vim.split(name, ".", { plain = true })[1]
end

local function post_to(path, async)
  async = async or false

  local opts = {}
  if async then
    opts.callback = function(out)
      if out.status ~= 200 then
        print("Network error. Is the server running?")
      end
    end
  end

  local curl = require("plenary.curl")
  curl.post("localhost:42069/" .. path, opts)
end

local function open_proj(name)
  local function openfile(path)
    if vim.fn.filereadable(path) == 1 then
      vim.cmd("e " .. path)
    end
  end

  local path = vim.fn.getcwd() .. "/" .. name .. "/" .. name
  openfile(path .. ".cpp")
  openfile(path .. ".in")
  openfile(path .. ".out")
end

M.fstream_proj = function()
  vim.ui.input({
      prompt = "Fstream project name",
    },
    function(input)
      if input == nil then
        return
      end

      local post = "create/f/" .. input
      post_to(post)

      open_proj(input)
    end
  )
end

M.istream_proj = function()
  vim.ui.input({ prompt = "Iostream project name" },
    function(input)
      if input == nil then
        return
      end

      local post = "create/i/" .. input
      post_to(post)

      open_proj(input)
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

      open_proj(input)
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

  local post = "run/" .. name
  post_to(post, true)
end

return M
