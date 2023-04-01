return function(modtime, loadlua, formatpath)
  loadlua = loadlua or load
  formatpath = formatpath or function(path) return path end

  local M = {
    modules = {
    },
    onreloads = {},
  }

  local function extendTable(dest, src)
    local visited = {}

    local function copyTable(src, dest)
      for k, v in pairs(src) do
        if type(v) == "table" then
          if visited[v] then
            dest[k] = visited[v]
          else
            visited[v] = {}
            dest[k] = {}
            copyTable(v, dest[k])
          end
        else
          dest[k] = v
        end
      end

      local mt = getmetatable(src)
      if mt then
        setmetatable(dest, mt)
      end
    end

    copyTable(src, dest)
  end

  function M.ext(a, b) return extendTable(a, b) end

  function M.deepcopy(orig, copies)
    copies = copies or {}
    local copy = {}
    if type(orig) == 'table' then
      if copies[orig] then
        return copies[orig]
      end
      copies[orig] = copy
      for k, v in next, orig, nil do
        copy[M.deepcopy(k, copies)] = M.deepcopy(v, copies)
      end
      setmetatable(copy, M.deepcopy(getmetatable(orig), copies))
    else
      copy = orig
    end
    return copy
  end

  function M.module(tbl)
    tbl.__module_id = rawget(_G, "tostring")(tbl)
    tbl.__default_table = M.deepcopy(tbl)

    tbl.onModuleLoad = tbl.onModuleLoad or function()
        end

    function tbl:resetModule()
      return M.ext(self, self.__default_table)
    end

    M.modules[tbl.__module_id] = tbl
    return tbl
  end

  function M:reloadModule(mod)
    if mod.__module_resets then
      mod:resetModule()
    end
    mod:onModuleLoad()
  end

  function M:load()
    for _, mod in pairs(self.modules) do
      M:reloadModule(mod)
    end
  end

  function M:loadModule(path)
    path = formatpath(path)

    local ok, chunk, err = pcall(loadlua, path)

    if not ok then
      print("Failed loading code: " .. chunk)
      return false
    end

    if not chunk then
      print("Failed reading file: " .. err)
      return false
    end

    return pcall(chunk)
  end

  function M:use(path, reset)
    local ok, value = M:loadModule(path)

    if not ok then
      print(value)
      return false
    end

    if type(value) == "table" and
        value["__module_id"] ~= nil then
      value.__last_modtime = modtime(formatpath(path))
      value.__module_path = path
      value.__module_resets = reset
      M.modules[value.__module_id] = value
    end

    return value
  end

  function M:update()
    local updated = {}

    for _, m in pairs(self.modules) do
      local now = modtime(m.__module_path)

      if now ~= m.__last_modtime then
        now = m.__last_modtime

        local _, mod = M:loadModule(m.__module_path)
        table.insert(updated, mod)
      end
    end

    for i = 1, #updated do
      local mod = updated[i]
      print("[ RELOADING: " .. mod.__module_path .. " ]")
      M:reloadModule(mod)
    end
  end

  function M:onreload(callback)
    table.insert(self.onreloads, callback)
  end

  return setmetatable(M, {
    __call = function(_, ...)
      return M:use(...)
    end
  })
end
